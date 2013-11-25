:: this assumes MinGW/MSYS has been installed in  c:\mingw
set MINGW_INSTOP=c:\mingw
set msys_bat=%MINGW_INSTOP%\msys\1.0\msys.bat
set temp_inst=c:\temp_inst\
if not exist %temp_inst%bin mkdir %temp_inst%bin
if not exist %temp_inst%lib mkdir %temp_inst%lib
if not exist %temp_inst%include mkdir %temp_inst%include

set LIB=%inst_temp%lib;%LIB%
set INCLUDE=%inst_temp%iinclude;%INCLUDE%

clone https://github.com/YannNayn/msvc_sup.git
pushd msvc_sup
nmake -f Makefile.msvc CFG=dll-release
popd
copy /Y msvc_sup\msvc100\src\dll-release\*.dll %inst_temp%bin
copy /Y msvc_sup\msvc100\src\dll-release\*.lib %inst_temp%lib
copy /Y msvc_sup\include\*.h %inst_temp%include

curl -o %inst_temp%lib\pthreadVC2.lib http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/lib/x86/pthreadVC2.lib
curl -o %inst_temp%bin\pthreadVC2.dll http://mirrors.kernel.org/sources.redhat.com/pthreads-win32/dll-latest/dll/x86/pthreadVC2.dll

clone https://github.com/YannNayn/check_msvc.git
pushd check_msvc
set src_dir=%CD%
call %msys_bat% -c "cd %src_dir:\=/% && configure --prefix=%temp_inst:\=/% && make && make install"
LIB /DEF:src\.libs\libcheck-0.dll.def /MACHINE:X86 /OUT:%inst_temp%lib\libcheck.lib
popd

clone https://github.com/YannNayn/hsregex_msvc.git
pushd hsregex_msvc
nmake -f Makefile.msvc CFG=dll-release
popd

copy /Y hsregex_msvc\msvc100\src\dll-release\*.dll %inst_temp%bin
copy /Y hsregex_msvc\msvc100\src\dll-release\*.lib %inst_temp%lib
copy /Y hsregex_msvc\hsregex.h %inst_temp%include

clone https://github.com/YannNayn/galera_msvc.git
pushd galera_msvc
scons galerautils
scons gcache
scons galera
scons gcomm
scons gcs
scons garb
popd

