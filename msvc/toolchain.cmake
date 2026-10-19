# Cross-compile OpenComposite for 64-bit Windows with clang-cl and lld-link, against Microsoft's
# CRT, STL, ATL and Windows SDK as downloaded by xwin (https://github.com/Jake-Shadle/xwin):
#   xwin --accept-license --arch x86_64 --include-atl splat --output ~/.xwin
#   msvc/vulkan.sh
#   cmake -S . -B build-msvc -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=msvc/toolchain.cmake
#   ninja -C build-msvc
# XWIN (default ~/.xwin) is the splat directory; LLVM_BIN holds clang-cl, llvm-rc, llvm-mt and llvm-lib.
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR AMD64)

if (NOT XWIN)
	set(XWIN "$ENV{XWIN}")
endif ()
if (NOT XWIN)
	set(XWIN "$ENV{HOME}/.xwin")
endif ()
if (NOT LLVM_BIN)
	set(LLVM_BIN "$ENV{LLVM_BIN}")
endif ()
if (NOT LLVM_BIN)
	set(LLVM_BIN "/opt/homebrew/opt/llvm/bin")
endif ()
# try_compile projects need these too
list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES XWIN LLVM_BIN)

set(CMAKE_C_COMPILER "${LLVM_BIN}/clang-cl")
set(CMAKE_CXX_COMPILER "${LLVM_BIN}/clang-cl")
# Homebrew ships lld-link in its own formula.
find_program(CMAKE_LINKER lld-link HINTS "${LLVM_BIN}" /opt/homebrew/opt/lld/bin REQUIRED)
set(CMAKE_RC_COMPILER "${LLVM_BIN}/llvm-rc")
set(CMAKE_MT "${LLVM_BIN}/llvm-mt")
set(CMAKE_AR "${LLVM_BIN}/llvm-lib")
set(CMAKE_C_COMPILER_TARGET x86_64-pc-windows-msvc)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-windows-msvc)

set(_inc "/imsvc ${XWIN}/crt/include /imsvc ${XWIN}/sdk/include/ucrt /imsvc ${XWIN}/sdk/include/um /imsvc ${XWIN}/sdk/include/shared /imsvc ${XWIN}/sdk/include/winrt")
set(CMAKE_C_FLAGS_INIT "${_inc}")
set(CMAKE_CXX_FLAGS_INIT "${_inc}")
# llvm-rc only searches the directories it's given.
set(CMAKE_RC_FLAGS_INIT "-I ${XWIN}/sdk/include/um -I ${XWIN}/sdk/include/shared -I ${XWIN}/crt/include -I ${XWIN}/sdk/include/ucrt")
set(_lib "/libpath:${XWIN}/crt/lib/x86_64 /libpath:${XWIN}/sdk/lib/um/x86_64 /libpath:${XWIN}/sdk/lib/ucrt/x86_64")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${_lib}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${_lib}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${_lib}")

# Link the C and C++ runtime statically, since a game may have installed an older msvcp140.dll
# into its prefix, and that one would be loaded instead.
set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreaded)

# xwin leaves out the debug CRT, so CMake's compiler checks use Release.
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
