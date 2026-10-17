#!/bin/sh
# Fills libs/vulkan, as the Windows build expects: the Vulkan headers, and an import library for
# vulkan-1.dll made from them. VULKAN_INCLUDE is the directory that contains vulkan/vulkan.h.
set -e
cd "$(dirname "$0")/.."
inc=${VULKAN_INCLUDE:-$(brew --prefix 2>/dev/null)/include}
[ -f "$inc/vulkan/vulkan_core.h" ] || { echo "no Vulkan headers in $inc; set VULKAN_INCLUDE" >&2; exit 1; }
mkdir -p libs/vulkan/Include libs/vulkan/Lib
cp -RL "$inc/vulkan" libs/vulkan/Include/
[ -d "$inc/vk_video" ] && cp -RL "$inc/vk_video" libs/vulkan/Include/
{
	echo "LIBRARY vulkan-1.dll"
	echo EXPORTS
	grep -h -oE 'VKAPI_CALL vk[A-Za-z0-9]+' "$inc/vulkan/vulkan_core.h" "$inc/vulkan/vulkan_win32.h" | cut -d' ' -f2 | sort -u
} > libs/vulkan/Lib/vulkan-1.def
"${LLVM_BIN:-/opt/homebrew/opt/llvm/bin}/llvm-dlltool" -m i386:x86-64 -d libs/vulkan/Lib/vulkan-1.def -l libs/vulkan/Lib/vulkan-1.lib
echo "libs/vulkan is ready"
