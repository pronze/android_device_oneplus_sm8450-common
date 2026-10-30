/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/properties.h>

namespace android {
namespace init {
uint32_t InitPropertySet(const std::string& name, const std::string& value);
}  // namespace init
}  // namespace android

using android::base::GetProperty;
using android::init::InitPropertySet;

/*
 * Only for read-only properties. Properties that can be wrote to more
 * than once should be set in a typical init script (e.g. init.oplus.hw.rc)
 * after the original property has been set.
 */
void vendor_process_bootenv() {
    auto prjname = std::stoi(GetProperty("ro.boot.prjname", "0"));

    switch (prjname) {
        // lunaa
        case 21603: // CN
            InitPropertySet("ro.product.product.model", "RMX3361");
            break;
        case 21675: // IN
            InitPropertySet("ro.product.product.model", "RMX3360");
            break;
        case 21676: // EU
            InitPropertySet("ro.product.product.model", "RMX3363");
            break;
        // martini
        case 20820: // CN
            InitPropertySet("ro.product.product.model", "MT2110");
            break;
        case 20821: // IN
            InitPropertySet("ro.product.product.model", "MT2111");
            break;
        // wly
        case 20846: // CN
            InitPropertySet("ro.product.product.model", "NE2210");
            break;
        case 20847: // EU
            InitPropertySet("ro.product.product.model", "NE2213");
            break;
        case 20848: // IN
            InitPropertySet("ro.product.product.model", "NE2211");
            break;
        case 20849: // US
            InitPropertySet("ro.product.product.model", "NE2215");
            break;
        case 0x2084A: // TMO
            InitPropertySet("ro.product.product.model", "NE2217");
            break;
        default:
            LOG(ERROR) << "Unexpected project name: " << prjname;
    }
}
