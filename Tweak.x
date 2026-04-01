#import <Foundation/Foundation.h>
#import <Substrate/Substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// O'yinning asosiy manzilini topish
static uintptr_t _get_image_base_address() {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* name = _dyld_get_image_name(i);
        if (strstr(name, "ShadowTrackerExtra")) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// Original funksiyalar uchun pointerlar
float (*_original_GetShootIntervalFromEntity)(id self, SEL _cmd);
float (*_original_GetBulletFireSpeedFromEntity)(id self, SEL _cmd);

// 1. O'q otish intervalini hook qilish (2 barobar tezroq otish)
float _hooked_GetShootIntervalFromEntity(id self, SEL _cmd) {
    float originalInterval = _original_GetShootIntervalFromEntity(self, _cmd);
    return originalInterval * 0.5f; 
}

// 2. O'q uchish tezligini hook qilish (1.5 barobar tezroq)
float _hooked_GetBulletFireSpeedFromEntity(id self, SEL _cmd) {
    float originalSpeed = _original_GetBulletFireSpeedFromEntity(self, _cmd);
    return originalSpeed * 1.5f;
}

%ctor {
    uintptr_t baseAddress = _get_image_base_address();
    
    if (baseAddress != 0) {
        NSLog(@"[Tweak] PUBG ulanmoqda...");

        [span_0](start_span)// Rasmlardan olingan haqiqiy offsetlar[span_0](end_span)
        // GetShootIntervalFromEntity offset: 0x724968E
        // GetBulletFireSpeedFromEntity offset: 0x724866B
        
        MSHookFunction((void*)(baseAddress + 0x724968E), 
                       (void*)&_hooked_GetShootIntervalFromEntity, 
                       (void**)&_original_GetShootIntervalFromEntity);

        MSHookFunction((void*)(baseAddress + 0x724866B), 
                       (void*)&_hooked_GetBulletFireSpeedFromEntity, 
                       (void**)&_original_GetBulletFireSpeedFromEntity);

        // Muvaffaqiyatli yuklanganini bildirish uchun xabar
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tweak Active" 
                                        message:@"PUBG Tweak muvaffaqiyatli urildi!" 
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
        });
    }
}
