#ifndef SHELL_FAKE_LIBRETRO_H
#define SHELL_FAKE_LIBRETRO_H

#include "libretro.h"
#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Core info */
#define SHELL_FAKE_CORE_NAME "Shell Fake Core"
#define SHELL_FAKE_CORE_VERSION "1.0.0"

/* Video settings */
#define SHELL_FAKE_VIDEO_WIDTH 640
#define SHELL_FAKE_VIDEO_HEIGHT 480
#define SHELL_FAKE_VIDEO_FPS 60

/* Audio settings */
#define SHELL_FAKE_AUDIO_SAMPLE_RATE 44100

/* Maximum length for paths and commands */
#define MAX_PATH_LENGTH 1024
#define MAX_COMMAND_LENGTH 2048

/* Process state */
typedef enum {
    PROCESS_IDLE,
    PROCESS_RUNNING,
    PROCESS_FINISHED,
    PROCESS_ERROR
} process_state_t;

/* Shell configuration */
typedef struct {
    char shell_path[MAX_PATH_LENGTH];
    char script_path[MAX_PATH_LENGTH];
    char working_dir[MAX_PATH_LENGTH];
    int timeout_seconds;
    bool capture_output;
    bool interactive_mode;
    bool auto_restart;
} shell_config_t;

/* Core state */
typedef struct {
    shell_config_t config;
    process_state_t state;
    int process_pid;
    int exit_code;
    uint32_t *video_buffer;
    int16_t *audio_buffer;
    char output_buffer[8192];
    size_t output_length;
    bool content_loaded;
    char rom_path[MAX_PATH_LENGTH];
    uint32_t frame_count;
    time_t start_time;
} core_state_t;

/* Function declarations */
void shell_fake_log(enum retro_log_level level, const char *fmt, ...);
bool shell_fake_load_script(const char *path);
void shell_fake_execute_script(void);
void shell_fake_stop_script(void);
void shell_fake_restart_script(void);
void shell_fake_update_config(void);
void shell_fake_render_frame(void);
void shell_fake_render_text(const char *text, int x, int y, uint32_t color);
void shell_fake_clear_screen(uint32_t color);
char* shell_fake_get_shell_path(void);
bool shell_fake_is_script_running(void);
void shell_fake_handle_input(void);

/* Global state */
extern core_state_t core_state;
extern retro_environment_t environ_cb;
extern retro_video_refresh_t video_cb;
extern retro_audio_sample_t audio_cb;
extern retro_audio_sample_batch_t audio_batch_cb;
extern retro_input_poll_t input_poll_cb;
extern retro_input_state_t input_state_cb;

#ifdef __cplusplus
}
#endif

#endif /* SHELL_FAKE_LIBRETRO_H */