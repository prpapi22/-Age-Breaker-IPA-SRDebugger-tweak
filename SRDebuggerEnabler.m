// SRDebuggerEnabler - forces SRDebugger on: triple-tap trigger, top-left.
// RVAs are from the dump.cs (UnityFramework). Verify against your build.
#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <string.h>
#include <stdbool.h>

#define RVA_SETTINGS_IS_ENABLED     0x5C0F494
#define RVA_SETTINGS_ENABLE_TRIGGER 0x5C0F4A4
#define RVA_SETTINGS_TRIGGER_BEHAV  0x5C0F4AC
#define RVA_SETTINGS_TRIGGER_POS    0x5C0F7F0
#define RVA_SETTINGS_EVENTSYSTEM    0x5C0F828
#define RVA_SRDEBUG_INIT            0x5C0E3B0

static void (*MSHook)(void *, void *, void **);
static void (*orig_Init)(void *);
static volatile bool g_initCalled = false;
static uintptr_t g_base = 0;

static bool hk_true(void *self) { return true; }
static int  hk_zero(void *self) { return 0; }   // Enabled / TripleTap / TopLeft

static void hk_Init(void *mi) {
    g_initCalled = true;
    NSLog(@"[SRDE] SRDebug.Init called by game");
    if (orig_Init) orig_Init(mi);
}

static void install(uintptr_t base) {
    g_base = base;
    MSHook(
        (void *)(base + RVA_SETTINGS_IS_ENABLED),     (void *)hk_true, NULL);
    MSHook((void *)(base + RVA_SETTINGS_ENABLE_TRIGGER), (void *)hk_zero, NULL);
    MSHook((void *)(base + RVA_SETTINGS_TRIGGER_BEHAV),  (void *)hk_zero, NULL);
    MSHook((void *)(base + RVA_SETTINGS_TRIGGER_POS),    (void *)hk_zero, NULL);
    MSHook((void *)(base + RVA_SETTINGS_EVENTSYSTEM),    (void *)hk_true, NULL);
    MSHook((void *)(base + RVA_SRDEBUG_INIT), (void *)hk_Init, (void **)&orig_Init);
    NSLog(@"[SRDE] hooks installed, base=%p", (void *)base);

    // If the game never initialises SRDebugger, do it ourselves.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        if (!g_initCalled) {
            NSLog(@"[SRDE] game never called Init, calling it");
            void (*init)(void *) = (void (*)(void *))(g_base + RVA_SRDEBUG_INIT);
            init(NULL);
        }
    });
}

static void image_added(const struct mach_header *mh, intptr_t slide) {
    static bool done = false;
    if (done) return;
    Dl_info info;
    if (!dladdr(mh, &info) || !info.dli_fname) return;
    if (!strstr(info.dli_fname, "UnityFramework")) return;
    done = true;
    install((uintptr_t)mh);
}

__attribute__((constructor)) static void srde_main(void) {
    MSHook = dlsym(RTLD_DEFAULT, "MSHookFunction");
    if (!MSHook) {
        NSLog(@"[SRDE] MSHookFunction not found - load ElleKit/Substrate too");
        return;
    }
    _dyld_register_func_for_add_image(image_added);
}
