#import <Foundation/Foundation.h>
#import <Substrate/Substrate.h>
#import <mach-o/dyld.h>

static uintptr_t _get_image_base_address() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char* name = _dyld_get_image_name(i);
        if (strstr(name, "ShadowTrackerExtra")) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// Funksiyalar uchun pointerlar
float (*_original_Shoot)(id self, SEL _cmd);
float (*_original_Bullet)(id self, SEL _cmd);
float (*_original_Damage)(id self, SEL _cmd);

// 1. Tez otish
float _hooked_Shoot(id self, SEL _cmd) {
    return 0.05f; 
}

// 2. O'q tezligi (Instant Hit)
float _hooked_Bullet(id self, SEL _cmd) {
    return 9999.0f;
}

// 3. KUCHAYTIRILGAN ZARAR (Damage)
float _hooked_Damage(id self, SEL _cmd) {
    // Bu yerda qurol zarari 2-3 barobar oshirilgan (yoki xohlagan raqamingizni yozing)
    return 500.0f; 
}

%ctor {
    uintptr_t base = _get_image_base_address();
    if (base != 0) {
        // Tez otish offset
        MSHookFunction((void*)(base + 0x724968E), (void*)&_hooked_Shoot, (void**)&_original_Shoot);
        
        // O'q tezligi offset
        MSHookFunction((void*)(base + 0x724866B), (void*)&_hooked_Bullet, (void**)&_original_Bullet);
        
        // ZARAR (Damage) offset - Rasmingizdagi 0x718F3A7
        MSHookFunction((void*)(base + 0x718F3A7), (void*)&_hooked_Damage, (void**)&_original_Damage);

        NSLog(@"[Tweak] PUBG High Damage + Fast Shoot yuklandi!");
    }
}
