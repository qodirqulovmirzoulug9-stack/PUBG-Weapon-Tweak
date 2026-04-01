// Tweak.x fayli
// PUBG Mobile uchun qurol parametrlarini o'zgartirish
// Diqqat: Ushbu kodni ishlatishdan oldin, o'yinning aniq versiyasi uchun
// funksiya va o'zgaruvchi offsetlarini disassembler (IDA Pro, Ghidra) yordamida topishingiz shart.
// Noto'g'ri offsetlar o'yinning crash bo'lishiga olib kelishi mumkin.

#import <Foundation/Foundation.h>
#import <Substrate/Substrate.h>
#import <mach-o/dyld.h>

// O'yinning asosiy manzilini (Base Address) topish uchun yordamchi funksiya
// Bu funksiya ASLR (Address Space Layout Randomization) sababli offsetlar o'zgarganda muhim bo'ladi.
static uintptr_t _get_image_base_address() {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char* name = _dyld_get_image_name(i);
        // Sizning faylingiz nomi 'ShadowTrackerExtra' deb topilgan edi.
        if (strstr(name, "ShadowTrackerExtra")) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// Funksiya pointerlari
float (*_original_GetShootIntervalFromEntity)(id self, SEL _cmd);
float (*_original_GetBulletFireSpeedFromEntity)(id self, SEL _cmd);

// --- Hook qilingan funksiyalar --- //

// O'q otish intervalini kamaytirish (tezroq otish uchun)
// Bu funksiya qancha kichik qiymat qaytarsa, o'q otish shuncha tez bo'ladi.
float _hooked_GetShootIntervalFromEntity(id self, SEL _cmd) {
    float originalInterval = _original_GetShootIntervalFromEntity(self, _cmd);
    // Intervalni 50% ga kamaytirish (2 barobar tezroq otish)
    // Qiymatni 0.1 dan kichik qilmang, aks holda o'yin crash bo'lishi mumkin.
    return originalInterval * 0.5f; 
}

// O'q tezligini oshirish
float _hooked_GetBulletFireSpeedFromEntity(id self, SEL _cmd) {
    float originalSpeed = _original_GetBulletFireSpeedFromEntity(self, _cmd);
    // Tezlikni 50% ga oshirish
    return originalSpeed * 1.5f;
}

// BaseDamage uchun, agar u funksiya bo'lsa:
// float (*_original_GetBaseDamage)(id self, SEL _cmd);
// float _hooked_GetBaseDamage(id self, SEL _cmd) {
//     float originalDamage = _original_GetBaseDamage(self, _cmd);
//     return originalDamage * 2.0f; // Zararni 2 barobar oshirish
// }

// --- Kutubxona yuklanganda ishga tushadigan qism --- //
// Bu funksiya .dylib yuklanganda avtomatik ravishda chaqiriladi.
__attribute__((constructor))
static void tweak_init() {
    uintptr_t baseAddress = _get_image_base_address();
    if (baseAddress == 0) {
        NSLog(@"[PUBG Tweak] ShadowTrackerExtra base address topilmadi! Tweak ishga tushmadi.");
        return;
    }
    NSLog(@"[PUBG Tweak] ShadowTrackerExtra base address: 0x%lx", baseAddress);

    // !!! DIQQAT: Quyidagi offsetlar sizning o'yin versiyangiz uchun noto'g'ri bo'lishi mumkin. !!!
    // !!! Ularni disassembler (IDA Pro, Ghidra) yordamida topishingiz shart. !!!
    // !!! Noto'g'ri offsetlar o'yinning crash bo'lishiga olib keladi. !!!

    // Misol uchun, agar GetShootIntervalFromEntity funksiyasining haqiqiy offseti 0x123456 bo'lsa:
    // void* shootIntervalFuncPtr = (void*)(baseAddress + 0x123456);
    // MSHookFunction(shootIntervalFuncPtr, (void*)_hooked_GetShootIntervalFromEntity, (void**)&_original_GetShootIntervalFromEntity);

    // Misol uchun, agar GetBulletFireSpeedFromEntity funksiyasining haqiqiy offseti 0x789ABC bo'lsa:
    // void* bulletFireSpeedFuncPtr = (void*)(baseAddress + 0x789ABC);
    // MSHookFunction(bulletFireSpeedFuncPtr, (void*)_hooked_GetBulletFireSpeedFromEntity, (void**)&_original_GetBulletFireSpeedFromEntity);

    // Agar BaseDamage ham funksiya bo'lsa:
    // void* baseDamageFuncPtr = (void*)(baseAddress + 0xDEF012);
    // MSHookFunction(baseDamageFuncPtr, (void*)_hooked_GetBaseDamage, (void**)&_original_GetBaseDamage);

    NSLog(@"[PUBG Tweak] Tweak yuklandi. Offsetlarni tekshiring!");
}

// --- Qo'shimcha eslatmalar --- //
// 1. Crash bermaslik uchun eng muhimi - to'g'ri offsetlarni topishdir.
// 2. O'yin yangilanganda offsetlar o'zgarishi mumkin, shuning uchun har yangilanishdan keyin offsetlarni qayta tekshirish kerak.
// 3. Juda katta qiymatlar (masalan, juda tez otish yoki juda katta zarar) o'yinning ichki logikasini buzishi va baribir crashga olib kelishi mumkin.
// 4. Server tomonida tekshiruvlar bo'lsa, bu o'zgarishlar aniqlanishi va ban berilishiga sabab bo'lishi mumkin.
