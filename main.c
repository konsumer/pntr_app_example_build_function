#include "pntr_app.h"

bool Init(pntr_app* app) {
    return true;
}

bool Update(pntr_app* app, pntr_image* screen) {
    pntr_clear_background(screen, PNTR_WHITE);
    pntr_draw_circle_fill(screen, screen->width / 2, screen->height / 2, 100, PNTR_BLUE);
    return true;
}

void Close(pntr_app* app) {
}

pntr_app Main(int argc, char* argv[]) {
    return (pntr_app) {
        .width = 800,
        .height = 450,
        .title = "pntr_app",
        .init = Init,
        .update = Update,
        .close = Close,
        .fps = 60
    };
}