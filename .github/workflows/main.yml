#import <Foundation/Foundation.h>
#import <Substrate/Substrate.h>
#import <mach-o/dyld.h>

static uintptr_t get_base() {
    uintptr_t slide = _dyld_get_image_vmaddr_slide(0);
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "ShadowTrackerExtra")) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return slide;
}

float (*old_Shoot)(id self, SEL _cmd);
float new_Shoot(id self, SEL _cmd) { return 0.05f; }

float (*old_Bullet)(id self, SEL _cmd);
float new_Bullet(id self, SEL _cmd) { return 9999.0f; }

%ctor {
    uintptr_t base = get_base();
    if (base != 0) {
        MSHookFunction((void*)(base + 0x724968E), (void*)&new_Shoot, (void**)&old_Shoot);
        MSHookFunction((void*)(base + 0x724866B), (void*)&new_Bullet, (void**)&old_Bullet);
    }
}
