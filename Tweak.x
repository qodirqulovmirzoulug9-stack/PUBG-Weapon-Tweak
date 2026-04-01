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

// 1. O'q otish intervalini hook qilish
float _hooked_GetShootIntervalFromEntity(id self, SEL _cmd) {
    float originalInterval = _original_GetShootIntervalFromEntity(self, _cmd);
    return originalInterval * 0.5f; 
}

// 2. O'q uchish tezligini hook qilish
float _hooked_GetBulletFireSpeedFromEntity(id self, SEL _cmd) {
    float originalSpeed = _original_GetBulletFireSpeedFromEntity(self, _cmd);
    return originalSpeed * 1.5f;
}

%ctor {
    uintptr_t baseAddress = _get_image_base_address();
    
    if (baseAddress != 0) {
        // Loglarda chiqqan 'span_0' va 'start_span' xatolari bu qatorda noto'g'ri yozilgan koddan edi.
        // Ularni olib tashlab, to'g'ri offsetlarni ulaymiz:
        
        MSHookFunction((void*)(baseAddress + 0x724968E), 
                       (void*)&_hooked_GetShootIntervalFromEntity, 
                       (void**)&_original_GetShootIntervalFromEntity);

        MSHookFunction((void*)(baseAddress + 0x724866B), 
                       (void*)&_hooked_GetBulletFireSpeedFromEntity, 
                       (void**)&_original_GetBulletFireSpeedFromEntity);

        // UIAlertController xatosini (keyWindow deprecated) tuzatish:
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *window = nil;
            if (@available(iOS 13.0, *)) {
                for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                    if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                        for (UIWindow *w in windowScene.windows) {
                            if (w.isKeyWindow) {
                                window = w;
                                break;
                            }
                        }
                    }
                }
            } else {
                window = [UIApplication sharedApplication].keyWindow;
            }

            if (window) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tweak Active" 
                                            message:@"PUBG Tweak muvaffaqiyatli ishga tushdi!" 
                                            preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [window.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        });
    }
}
