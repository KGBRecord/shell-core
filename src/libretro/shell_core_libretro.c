/*
    Shell Core - LibRetro core for executing shell scripts
    
    This file is part of Shell Core.

    Shell Core is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Shell Core is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Shell Core.  If not, see <http://www.gnu.org/licenses/>
*/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <time.h>
#include <errno.h>

#ifdef __unix__
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>
#elif _WIN32
#include <windows.h>
#include <process.h>
#endif

#include "shell_core_libretro.h"

/* Global callbacks */
retro_environment_t environ_cb;
retro_video_refresh_t video_cb;
retro_audio_sample_t audio_cb;
retro_audio_sample_batch_t audio_batch_cb;
retro_input_poll_t input_poll_cb;
retro_input_state_t input_state_cb;

/* Global state */
core_state_t core_state;
static struct retro_log_callback logging;
static retro_log_printf_t log_cb;

static void safe_copy(char *dst, size_t dst_size, const char *src)
{
    if (!dst || dst_size == 0) return;
    if (!src) {
        dst[0] = '\0';
        return;
    }
    snprintf(dst, dst_size, "%s", src);
}

/* Core options */
static struct retro_core_option_v2_category shell_core_categories[] = {
    {
        "shell",
        "Shell Settings",
        "Configure shell execution parameters"
    },
    {
        "display",
        "Display Settings", 
        "Configure visual output options"
    },
    { NULL, NULL, NULL }
};

static struct retro_core_option_v2_definition shell_core_options[] = {
    {
        "shell_core_shell",
        "Shell Interpreter",
        "Shell interpreter to use for script execution",
        "Choose the shell that will execute your scripts. bash is recommended for compatibility.",
        NULL,
        "shell",
        {
            { "bash", "Bash" },
            { "zsh", "Zsh" },
            { "sh", "Bourne Shell" },
            { "fish", "Fish Shell" },
            { "dash", "Dash" },
            { NULL, NULL }
        },
        "bash"
    },
    {
        "shell_core_timeout",
        "Script Timeout",
        "Maximum time (in seconds) to run a script",
        "Set timeout for script execution. 0 means no timeout (infinite).",
        NULL,
        "shell",
        {
            { "0", "No timeout" },
            { "5", "5 seconds" },
            { "10", "10 seconds" },
            { "30", "30 seconds" },
            { "60", "1 minute" },
            { "300", "5 minutes" },
            { "600", "10 minutes" },
            { NULL, NULL }
        },
        "60"
    },
    {
        "shell_core_working_dir",
        "Working Directory",
        "Working directory for script execution",
        "Choose where scripts should be executed from.",
        NULL,
        "shell",
        {
            { "script_dir", "Script Directory" },
            { "home", "Home Directory" },
            { "tmp", "Temp Directory" },
            { "current", "Current Directory" },
            { NULL, NULL }
        },
        "script_dir"
    },
    {
        "shell_core_capture_output",
        "Capture Output",
        "Capture and display script output",
        "When enabled, script output will be captured and displayed on screen.",
        NULL,
        "display",
        {
            { "enabled", "Enabled" },
            { "disabled", "Disabled" },
            { NULL, NULL }
        },
        "enabled"
    },
    {
        "shell_core_interactive",
        "Interactive Mode",
        "Allow interactive input for scripts",
        "Enable if your scripts require user input.",
        NULL,
        "shell",
        {
            { "enabled", "Enabled" },
            { "disabled", "Disabled" },
            { NULL, NULL }
        },
        "disabled"
    },
    {
        "shell_core_auto_restart",
        "Auto Restart",
        "Automatically restart finished scripts",
        "When enabled, scripts will restart automatically after finishing.",
        NULL,
        "shell",
        {
            { "enabled", "Enabled" },
            { "disabled", "Disabled" },
            { NULL, NULL }
        },
        "disabled"
    },
    {
        "shell_core_font_size", 
        "Font Size",
        "Font size for text output",
        "Adjust the size of text displayed on screen.",
        NULL,
        "display",
        {
            { "small", "Small" },
            { "medium", "Medium" },
            { "large", "Large" },
            { NULL, NULL }
        },
        "medium"
    },
    { NULL, NULL, NULL, NULL, NULL, NULL, { { NULL, NULL } }, NULL }
};

static struct retro_core_options_v2 shell_core_options_v2 = {
    shell_core_categories,
    shell_core_options
};

/* Input descriptors */
static const struct retro_input_descriptor input_descriptors[] = {
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_LEFT,  "Left" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_UP,    "Up" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_DOWN,  "Down" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_RIGHT, "Right" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_A,     "Restart Script" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_B,     "Stop Script" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_X,     "Toggle Output" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_Y,     "Clear Output" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_START, "Pause/Resume" },
    { 0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_SELECT,"Menu" },
    { 0 }
};

/* Controller info */
static const struct retro_controller_description port_1[] = {
    { "Shell Controller", RETRO_DEVICE_JOYPAD },
    { 0 }
};

static const struct retro_controller_info controller_ports[] = {
    { port_1, 1 },
    { 0 }
};

/* Font data for text rendering (simple 8x8 bitmap) */
static const uint8_t font_8x8[128][8] = {
    /* Simple ASCII font data would go here */
    /* For brevity, we'll implement basic characters */
    [' '] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00},
    ['A'] = {0x3C, 0x42, 0x42, 0x7E, 0x42, 0x42, 0x42, 0x00},
    ['B'] = {0x7C, 0x42, 0x42, 0x7C, 0x42, 0x42, 0x7C, 0x00},
    /* ... more characters would be added here ... */
};

/* Fallback logging function */
#if defined(__clang__) || defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wformat-nonliteral"
#endif
static void fallback_log(enum retro_log_level level, const char *fmt, ...)
{
    (void)level;
    va_list va;
    va_start(va, fmt);
    vfprintf(stderr, fmt, va);
    va_end(va);
}

/* Logging function */
void shell_core_log(enum retro_log_level level, const char *fmt, ...)
{
    va_list va;
    char message[2048];

    va_start(va, fmt);
    vsnprintf(message, sizeof(message), fmt, va);
    va_end(va);

    if (log_cb) {
        log_cb(level, "[Shell Core] %s", message);
    } else {
        fprintf(stderr, "[Shell Core] %s", message);
    }
}
#if defined(__clang__) || defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

/* Initialize core state */
static void init_core_state(void)
{
    memset(&core_state, 0, sizeof(core_state_t));
    
    /* Set default configuration */
    safe_copy(core_state.config.shell_path, sizeof(core_state.config.shell_path), "/bin/bash");
    safe_copy(core_state.config.working_dir, sizeof(core_state.config.working_dir), ".");
    core_state.config.timeout_seconds = 60;
    core_state.config.capture_output = true;
    core_state.config.interactive_mode = false;
    core_state.config.auto_restart = false;
    
    core_state.state = PROCESS_IDLE;
    core_state.process_pid = -1;
    core_state.exit_code = 0;
    
    /* Allocate video buffer */
    core_state.video_buffer = calloc(SHELL_CORE_VIDEO_WIDTH * SHELL_CORE_VIDEO_HEIGHT, sizeof(uint32_t));
    if (!core_state.video_buffer) {
        shell_core_log(RETRO_LOG_ERROR, "Failed to allocate video buffer\n");
    }
    
    /* Allocate audio buffer */
    core_state.audio_buffer = calloc(SHELL_CORE_AUDIO_SAMPLE_RATE / SHELL_CORE_VIDEO_FPS * 2, sizeof(int16_t));
    if (!core_state.audio_buffer) {
        shell_core_log(RETRO_LOG_ERROR, "Failed to allocate audio buffer\n");
    }
}

/* Get shell path based on configuration */
const char* shell_core_get_shell_path(void)
{
    struct retro_variable var = {0};
    
    var.key = "shell_core_shell";
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
        if (strcmp(var.value, "bash") == 0) {
            return "/bin/bash";
        } else if (strcmp(var.value, "zsh") == 0) {
            return "/bin/zsh";
        } else if (strcmp(var.value, "sh") == 0) {
            return "/bin/sh";
        } else if (strcmp(var.value, "fish") == 0) {
            return "/usr/bin/fish";
        } else if (strcmp(var.value, "dash") == 0) {
            return "/bin/dash";
        }
    }
    
    return "/bin/bash"; /* default */
}

/* Update configuration from core options */
void shell_core_update_config(void)
{
    struct retro_variable var = {0};
    
    /* Update shell path */
    safe_copy(core_state.config.shell_path, sizeof(core_state.config.shell_path), shell_core_get_shell_path());
    
    /* Update timeout */
    var.key = "shell_core_timeout";
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
        core_state.config.timeout_seconds = atoi(var.value);
    }
    
    /* Update working directory */
    var.key = "shell_core_working_dir";
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
        if (strcmp(var.value, "script_dir") == 0) {
            /* Extract directory from script path */
            char *last_slash = strrchr(core_state.config.script_path, '/');
            if (last_slash) {
                strncpy(core_state.config.working_dir, core_state.config.script_path, 
                       last_slash - core_state.config.script_path);
                core_state.config.working_dir[last_slash - core_state.config.script_path] = '\0';
            }
        } else if (strcmp(var.value, "home") == 0) {
            safe_copy(core_state.config.working_dir, sizeof(core_state.config.working_dir),
                      getenv("HOME") ? getenv("HOME") : "/tmp");
        } else if (strcmp(var.value, "tmp") == 0) {
            safe_copy(core_state.config.working_dir, sizeof(core_state.config.working_dir), "/tmp");
        } else {
            safe_copy(core_state.config.working_dir, sizeof(core_state.config.working_dir), ".");
        }
    }
    
    /* Update capture output */
    var.key = "shell_core_capture_output";
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
        core_state.config.capture_output = (strcmp(var.value, "enabled") == 0);
    }
    
    /* Update interactive mode */
    var.key = "shell_core_interactive";
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
        core_state.config.interactive_mode = (strcmp(var.value, "enabled") == 0);
    }
    
    /* Update auto restart */
    var.key = "shell_core_auto_restart";
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE, &var) && var.value) {
        core_state.config.auto_restart = (strcmp(var.value, "enabled") == 0);
    }
}

/* Clear screen with specified color */
void shell_core_clear_screen(uint32_t color)
{
    if (!core_state.video_buffer) return;
    
    for (int i = 0; i < SHELL_CORE_VIDEO_WIDTH * SHELL_CORE_VIDEO_HEIGHT; i++) {
        core_state.video_buffer[i] = color;
    }
}

/* Render text at specified position */
void shell_core_render_text(const char *text, int x, int y, uint32_t color)
{
    if (!core_state.video_buffer || !text) return;

    /* Support line breaks and simple wrapping to avoid drawing off-screen text. */
    int cursor_x = x;
    int cursor_y = y;
    const char *p = text;

    while (*p && cursor_y < SHELL_CORE_VIDEO_HEIGHT) {
        unsigned char c = (unsigned char)*p++;

        if (c == '\n') {
            cursor_x = x;
            cursor_y += 8;
            continue;
        }

        if (c >= 128) c = '?';

        if (cursor_x + 8 > SHELL_CORE_VIDEO_WIDTH) {
            cursor_x = x;
            cursor_y += 8;
            if (cursor_y >= SHELL_CORE_VIDEO_HEIGHT) break;
        }

        if (cursor_x >= 0 && cursor_y >= -7) {
            for (int row = 0; row < 8; row++) {
                uint8_t line = font_8x8[c][row];
                int py = cursor_y + row;
                if (line == 0 || py < 0 || py >= SHELL_CORE_VIDEO_HEIGHT) continue;

                uint32_t *pixel = &core_state.video_buffer[py * SHELL_CORE_VIDEO_WIDTH + cursor_x];
                for (int col = 0; col < 8; col++) {
                    if ((line & (0x80 >> col)) && (cursor_x + col) < SHELL_CORE_VIDEO_WIDTH) {
                        pixel[col] = color;
                    }
                }
            }
        }

        cursor_x += 8;
    }
}

/* Check if script is currently running */
bool shell_core_is_script_running(void)
{
    if (core_state.process_pid <= 0) return false;
    
#ifdef __unix__
    int status;
    pid_t result = waitpid(core_state.process_pid, &status, WNOHANG);
    if (result == core_state.process_pid) {
        if (WIFEXITED(status)) {
            core_state.exit_code = WEXITSTATUS(status);
        } else if (WIFSIGNALED(status)) {
            core_state.exit_code = 128 + WTERMSIG(status);
        } else {
            core_state.exit_code = 1;
        }
        core_state.state = PROCESS_FINISHED;
        core_state.process_pid = -1;
        return false;
    }
    if (result == 0) {
        return true;
    }
#elif _WIN32
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, core_state.process_pid);
    if (hProcess) {
        DWORD exit_code;
        if (GetExitCodeProcess(hProcess, &exit_code)) {
            if (exit_code != STILL_ACTIVE) {
                core_state.exit_code = exit_code;
                core_state.state = PROCESS_FINISHED;
                core_state.process_pid = -1;
                CloseHandle(hProcess);
                return false;
            }
        }
        CloseHandle(hProcess);
        return true;
    }
#endif
    
    return false;
}

/* Execute the loaded script */
void shell_core_execute_script(void)
{
    if (!core_state.content_loaded || strlen(core_state.config.script_path) == 0) {
        shell_core_log(RETRO_LOG_ERROR, "No script loaded\n");
        return;
    }
    
    if (shell_core_is_script_running()) {
        shell_core_log(RETRO_LOG_INFO, "Script already running\n");
        return;
    }
    
    shell_core_log(RETRO_LOG_INFO, "Executing script: %s\n", core_state.config.script_path);
    shell_core_log(RETRO_LOG_INFO, "Using shell: %s\n", core_state.config.shell_path);
    shell_core_log(RETRO_LOG_INFO, "Working directory: %s\n", core_state.config.working_dir);
    
    core_state.state = PROCESS_RUNNING;
    core_state.start_time = time(NULL);
    
#ifdef __unix__
    pid_t pid = fork();
    if (pid == 0) {
        /* Child process */
        if (chdir(core_state.config.working_dir) != 0) {
            shell_core_log(RETRO_LOG_WARN, "Failed to change directory: %s\n", strerror(errno));
        }
        
        execl(core_state.config.shell_path, core_state.config.shell_path, 
              core_state.config.script_path, (char*)NULL);
        exit(1); /* execl failed */
    } else if (pid > 0) {
        /* Parent process */
        core_state.process_pid = pid;
        shell_core_log(RETRO_LOG_INFO, "Script started with PID: %d\n", pid);
    } else {
        /* Fork failed */
        shell_core_log(RETRO_LOG_ERROR, "Failed to fork process: %s\n", strerror(errno));
        core_state.state = PROCESS_ERROR;
    }
#elif _WIN32
    /* Windows implementation would use CreateProcess */
    shell_core_log(RETRO_LOG_WARN, "Windows execution not fully implemented\n");
    core_state.state = PROCESS_ERROR;
#endif
}

/* Stop the running script */
void shell_core_stop_script(void)
{
    if (!shell_core_is_script_running()) return;
    
    shell_core_log(RETRO_LOG_INFO, "Stopping script PID: %d\n", core_state.process_pid);
    
#ifdef __unix__
    kill(core_state.process_pid, SIGTERM);
    sleep(1);
    if (kill(core_state.process_pid, 0) == 0) {
        /* Still running, force kill */
        kill(core_state.process_pid, SIGKILL);
    }
#elif _WIN32
    HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, core_state.process_pid);
    if (hProcess) {
        TerminateProcess(hProcess, 1);
        CloseHandle(hProcess);
    }
#endif
    
    core_state.process_pid = -1;
    core_state.state = PROCESS_IDLE;
}

/* Restart the script */
void shell_core_restart_script(void)
{
    shell_core_stop_script();
    shell_core_execute_script();
}

/* Load script file */
bool shell_core_load_script(const char *path)
{
    if (!path || strlen(path) == 0) {
        shell_core_log(RETRO_LOG_ERROR, "Invalid script path\n");
        return false;
    }
    
    /* Check if file exists and is readable */
    FILE *f = fopen(path, "r");
    if (!f) {
        shell_core_log(RETRO_LOG_ERROR, "Cannot open script file: %s\n", path);
        return false;
    }
    fclose(f);
    
    strncpy(core_state.config.script_path, path, MAX_PATH_LENGTH - 1);
    core_state.config.script_path[MAX_PATH_LENGTH - 1] = '\0';
    core_state.content_loaded = true;
    
    /* Update configuration based on new script */
    shell_core_update_config();
    
    shell_core_log(RETRO_LOG_INFO, "Script loaded: %s\n", path);
    return true;
}

/* Handle input from controller */
void shell_core_handle_input(void)
{
    if (!input_poll_cb || !input_state_cb) return;
    
    input_poll_cb();
    
    static bool prev_buttons[16] = {false};
    bool curr_buttons[16] = {false};
    
    /* Read current button states */
    curr_buttons[RETRO_DEVICE_ID_JOYPAD_A] = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_A);
    curr_buttons[RETRO_DEVICE_ID_JOYPAD_B] = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_B);
    curr_buttons[RETRO_DEVICE_ID_JOYPAD_X] = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_X);
    curr_buttons[RETRO_DEVICE_ID_JOYPAD_Y] = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_Y);
    curr_buttons[RETRO_DEVICE_ID_JOYPAD_START] = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_START);
    curr_buttons[RETRO_DEVICE_ID_JOYPAD_SELECT] = input_state_cb(0, RETRO_DEVICE_JOYPAD, 0, RETRO_DEVICE_ID_JOYPAD_SELECT);
    
    /* Handle button presses (on release to avoid repeats) */
    if (prev_buttons[RETRO_DEVICE_ID_JOYPAD_A] && !curr_buttons[RETRO_DEVICE_ID_JOYPAD_A]) {
        /* A button: Restart script */
        shell_core_restart_script();
    }
    
    if (prev_buttons[RETRO_DEVICE_ID_JOYPAD_B] && !curr_buttons[RETRO_DEVICE_ID_JOYPAD_B]) {
        /* B button: Stop script */
        shell_core_stop_script();
    }
    
    if (prev_buttons[RETRO_DEVICE_ID_JOYPAD_Y] && !curr_buttons[RETRO_DEVICE_ID_JOYPAD_Y]) {
        /* Y button: Clear output */
        core_state.output_buffer[0] = '\0';
        core_state.output_length = 0;
    }
    
    if (prev_buttons[RETRO_DEVICE_ID_JOYPAD_START] && !curr_buttons[RETRO_DEVICE_ID_JOYPAD_START]) {
        /* Start button: Execute script if not running */
        if (!shell_core_is_script_running() && core_state.content_loaded) {
            shell_core_execute_script();
        }
    }
    
    /* Copy current to previous */
    memcpy(prev_buttons, curr_buttons, sizeof(prev_buttons));
}

/* Render frame */
void shell_core_render_frame(void)
{
    if (!core_state.video_buffer) return;
    
    /* Clear screen with dark blue */
    shell_core_clear_screen(0xFF001122);
    
    /* Render status information */
    char status_text[256];
    const char *state_str;
    
    switch (core_state.state) {
        case PROCESS_IDLE:    state_str = "IDLE"; break;
        case PROCESS_RUNNING: state_str = "RUNNING"; break;
        case PROCESS_FINISHED:state_str = "FINISHED"; break;
        case PROCESS_ERROR:   state_str = "ERROR"; break;
        default:              state_str = "UNKNOWN"; break;
    }
    
    snprintf(status_text, sizeof(status_text), "Shell Core - State: %s", state_str);
    shell_core_render_text(status_text, 10, 10, 0xFFFFFFFF);
    
    if (core_state.content_loaded) {
        snprintf(status_text, sizeof(status_text), "Script: %s", core_state.config.script_path);
        shell_core_render_text(status_text, 10, 30, 0xFFAAAAAA);
        
        snprintf(status_text, sizeof(status_text), "Shell: %s", core_state.config.shell_path);
        shell_core_render_text(status_text, 10, 50, 0xFFAAAAAA);
    }
    
    if (core_state.state == PROCESS_RUNNING) {
        snprintf(status_text, sizeof(status_text), "PID: %d", core_state.process_pid);
        shell_core_render_text(status_text, 10, 70, 0xFF00FF00);
        
        time_t elapsed = time(NULL) - core_state.start_time;
        snprintf(status_text, sizeof(status_text), "Running for: %ld seconds", elapsed);
        shell_core_render_text(status_text, 10, 90, 0xFF00FF00);
    }
    
    if (core_state.state == PROCESS_FINISHED) {
        snprintf(status_text, sizeof(status_text), "Exit code: %d", core_state.exit_code);
        shell_core_render_text(status_text, 10, 70, 
                              core_state.exit_code == 0 ? 0xFF00FF00 : 0xFFFF0000);
                              
        if (core_state.config.auto_restart) {
            shell_core_render_text("Auto-restart enabled", 10, 90, 0xFFFFFF00);
        }
    }
    
    /* Render controls */
    shell_core_render_text("Controls:", 10, 130, 0xFFFFFFFF);
    shell_core_render_text("A - Restart    B - Stop", 10, 150, 0xFFCCCCCC);
    shell_core_render_text("Y - Clear      START - Run", 10, 170, 0xFFCCCCCC);
    
    /* Render output if available */
    if (core_state.config.capture_output && core_state.output_length > 0) {
        const size_t output_render_limit = 1024;
        const char *output_to_render = core_state.output_buffer;
        size_t output_len = core_state.output_length;

        if (output_len > output_render_limit) {
            output_to_render = core_state.output_buffer + (output_len - output_render_limit);
            while (*output_to_render && *output_to_render != '\n')
                output_to_render++;
            if (*output_to_render == '\n')
                output_to_render++;
        }

        shell_core_render_text("Output:", 10, 210, 0xFFFFFFFF);
        shell_core_render_text(output_to_render, 10, 230, 0xFF00FFFF);
    }
    
    core_state.frame_count++;
}

/* LibRetro API implementation */

void retro_init(void)
{
    init_core_state();
    shell_core_log(RETRO_LOG_INFO, "Shell Core initialized\n");
}

void retro_deinit(void)
{
    shell_core_stop_script();
    
    if (core_state.video_buffer) {
        free(core_state.video_buffer);
        core_state.video_buffer = NULL;
    }
    
    if (core_state.audio_buffer) {
        free(core_state.audio_buffer);
        core_state.audio_buffer = NULL;
    }
    
    shell_core_log(RETRO_LOG_INFO, "Shell Core deinitialized\n");
}

unsigned retro_api_version(void)
{
    return RETRO_API_VERSION;
}

void retro_set_controller_port_device(unsigned port, unsigned device)
{
    (void)port;
    (void)device;
}

void retro_get_system_info(struct retro_system_info *info)
{
    memset(info, 0, sizeof(*info));
    info->library_name     = SHELL_CORE_NAME;
    info->library_version  = SHELL_CORE_VERSION;
    info->need_fullpath    = true;
    info->valid_extensions = "sh";
}

void retro_get_system_av_info(struct retro_system_av_info *info)
{
    info->timing.fps = SHELL_CORE_VIDEO_FPS;
    info->timing.sample_rate = SHELL_CORE_AUDIO_SAMPLE_RATE;
    
    info->geometry.base_width   = SHELL_CORE_VIDEO_WIDTH;
    info->geometry.base_height  = SHELL_CORE_VIDEO_HEIGHT;
    info->geometry.max_width    = SHELL_CORE_VIDEO_WIDTH;
    info->geometry.max_height   = SHELL_CORE_VIDEO_HEIGHT;
    info->geometry.aspect_ratio = (float)SHELL_CORE_VIDEO_WIDTH / (float)SHELL_CORE_VIDEO_HEIGHT;
}

void retro_set_environment(retro_environment_t cb)
{
    environ_cb = cb;
    
    /* Logging */
    if (cb(RETRO_ENVIRONMENT_GET_LOG_INTERFACE, &logging)) {
        log_cb = logging.log;
    } else {
        log_cb = fallback_log;
    }
    
    /* Core options */
    cb(RETRO_ENVIRONMENT_SET_CORE_OPTIONS_V2, &shell_core_options_v2);
    
    /* Input descriptors */
    cb(RETRO_ENVIRONMENT_SET_INPUT_DESCRIPTORS, (void*)input_descriptors);
    
    /* Controller info */
    cb(RETRO_ENVIRONMENT_SET_CONTROLLER_INFO, (void*)controller_ports);
    
    /* Pixel format */
    enum retro_pixel_format fmt = RETRO_PIXEL_FORMAT_XRGB8888;
    cb(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, &fmt);
}

void retro_set_audio_sample(retro_audio_sample_t cb)
{
    audio_cb = cb;
}

void retro_set_audio_sample_batch(retro_audio_sample_batch_t cb)
{
    audio_batch_cb = cb;
}

void retro_set_input_poll(retro_input_poll_t cb)
{
    input_poll_cb = cb;
}

void retro_set_input_state(retro_input_state_t cb)
{
    input_state_cb = cb;
}

void retro_set_video_refresh(retro_video_refresh_t cb)
{
    video_cb = cb;
}

void retro_reset(void)
{
    shell_core_restart_script();
}

void retro_run(void)
{
    bool updated = false;
    bool should_redraw = false;
    static process_state_t last_state = PROCESS_ERROR;
    static int last_exit_code = -9999;
    static bool last_content_loaded = false;
    static size_t last_output_length = 0;
    static time_t last_elapsed_seconds = -1;
    
    /* Check for core option updates */
    if (environ_cb(RETRO_ENVIRONMENT_GET_VARIABLE_UPDATE, &updated) && updated) {
        shell_core_update_config();
        should_redraw = true;
    }
    
    /* Handle input */
    shell_core_handle_input();
    
    /* Check script status */
    if (core_state.state == PROCESS_RUNNING) {
        if (core_state.config.timeout_seconds > 0) {
            time_t elapsed = time(NULL) - core_state.start_time;
            if (elapsed >= core_state.config.timeout_seconds) {
                shell_core_log(RETRO_LOG_WARN, "Script timed out after %d seconds\n",
                               core_state.config.timeout_seconds);
                shell_core_stop_script();
                core_state.state = PROCESS_ERROR;
                core_state.exit_code = -1;
                should_redraw = true;
            }
        }

        if (!shell_core_is_script_running()) {
            if (core_state.config.auto_restart) {
                shell_core_execute_script();
                should_redraw = true;
            }
        }
    }

    if (core_state.state != last_state ||
        core_state.exit_code != last_exit_code ||
        core_state.content_loaded != last_content_loaded ||
        core_state.output_length != last_output_length) {
        should_redraw = true;
    }

    if (core_state.state == PROCESS_RUNNING) {
        time_t elapsed_seconds = time(NULL) - core_state.start_time;
        if (elapsed_seconds != last_elapsed_seconds)
            should_redraw = true;
        last_elapsed_seconds = elapsed_seconds;
    } else {
        last_elapsed_seconds = -1;
    }

    /* Periodic refresh even without state changes (UI heartbeat). */
    if ((core_state.frame_count % 4U) == 0U)
        should_redraw = true;

    if (should_redraw)
        shell_core_render_frame();

    last_state = core_state.state;
    last_exit_code = core_state.exit_code;
    last_content_loaded = core_state.content_loaded;
    last_output_length = core_state.output_length;
    
    /* Submit video */
    if (video_cb && core_state.video_buffer) {
        video_cb(core_state.video_buffer, SHELL_CORE_VIDEO_WIDTH, SHELL_CORE_VIDEO_HEIGHT, 
                SHELL_CORE_VIDEO_WIDTH * sizeof(uint32_t));
    }
    
    /* Submit audio (silence for now) */
    if (audio_batch_cb && core_state.audio_buffer) {
        memset(core_state.audio_buffer, 0, SHELL_CORE_AUDIO_SAMPLE_RATE / SHELL_CORE_VIDEO_FPS * 2 * sizeof(int16_t));
        audio_batch_cb(core_state.audio_buffer, SHELL_CORE_AUDIO_SAMPLE_RATE / SHELL_CORE_VIDEO_FPS);
    }
}

bool retro_load_game(const struct retro_game_info *info)
{
    if (!info || !info->path) {
        shell_core_log(RETRO_LOG_ERROR, "No game info provided\n");
        return false;
    }
    
    safe_copy(core_state.rom_path, sizeof(core_state.rom_path), info->path);
    
    if (!shell_core_load_script(info->path)) {
        return false;
    }
    
    shell_core_log(RETRO_LOG_INFO, "Game loaded: %s\n", info->path);
    
    /* Auto-start script if configured */
    shell_core_execute_script();
    
    return true;
}

void retro_unload_game(void)
{
    shell_core_stop_script();
    core_state.content_loaded = false;
    memset(core_state.config.script_path, 0, sizeof(core_state.config.script_path));
    shell_core_log(RETRO_LOG_INFO, "Game unloaded\n");
}

unsigned retro_get_region(void)
{
    return RETRO_REGION_NTSC;
}

bool retro_load_game_special(unsigned type, const struct retro_game_info *info, size_t num)
{
    (void)type;
    (void)info;
    (void)num;
    return false;
}

size_t retro_serialize_size(void)
{
    return 0;
}

bool retro_serialize(void *data, size_t size)
{
    (void)data;
    (void)size;
    return false;
}

bool retro_unserialize(const void *data, size_t size)
{
    (void)data;
    (void)size;
    return false;
}

void *retro_get_memory_data(unsigned id)
{
    (void)id;
    return NULL;
}

size_t retro_get_memory_size(unsigned id)
{
    (void)id;
    return 0;
}

void retro_cheat_reset(void)
{
}

void retro_cheat_set(unsigned index, bool enabled, const char *code)
{
    (void)index;
    (void)enabled;
    (void)code;
}