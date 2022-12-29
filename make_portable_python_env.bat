@echo off
cls



:: Sets variables
set "project_name=MyProject"
set "python_version=3.10.9"



:: Downloads and extracts Python and Pip
if exist "python-%python_version%" rmdir "python-%python_version%"
mkdir "python-%python_version%"
call .\bin\wget.exe -c --no-check-certificate --progress=bar -O "python-%python_version%-embed-amd64.zip" "https://www.python.org/ftp/python/%python_version%/python-%python_version%-embed-amd64.zip"
call .\bin\wget.exe -c --no-check-certificate --progress=bar -O "get-pip.py" "https://bootstrap.pypa.io/get-pip.py"
call .\bin\unzip.exe "python-%python_version%-embed-amd64.zip" -d "python-%python_version%"
call move "get-pip.py" ".\python-%python_version%\get-pip.py"



:: Installs Pip
call .\python-%python_version%\python.exe .\python-%python_version%\get-pip.py



:: Finds and edits the ._pth config file
for %%f in (.\python-%python_version%\*._pth) do set "pth_file=%%~nf" goto :break
:break

echo Lib/site-packages>.\python-%python_version%\%pth_file%._pth
echo %pth_file%.zip>>.\python-%python_version%\%pth_file%._pth
echo .>>.\python-%python_version%\%pth_file%._pth
echo:>>.\python-%python_version%\%pth_file%._pth
echo # Uncomment to run site.main() automatically>>.\python-%python_version%\%pth_file%._pth
echo import site>>.\python-%python_version%\%pth_file%._pth



:: Installs Virtualenv
call .\python-%python_version%\python.exe -m pip install virtualenv



:: DLLs folder is required - ???
mkdir ".\python-%python_version%\DLLs"



:: Project setup
:: ===========================
mkdir "..\%project_name%"

:: Creates a virtual environment in the project folder
call .\python-%python_version%\python.exe -m virtualenv ..\%project_name%\venv
:: Copies embedded Python to the project folder
call copy /Y ".\python-%python_version%\%pth_file%.zip" "..\%project_name%\venv\Scripts"
:: Converts absolute paths to relative
call .\bin\sed.exe -i "/home = /c\home = .\\Scripts" "..\%project_name%\venv\pyvenv.cfg"
call .\bin\sed.exe -i "/include-system-site-packages = /c\include-system-site-packages = true" "..\%project_name%\venv\pyvenv.cfg"
call .\bin\sed.exe -i "/base-prefix = /c\base-prefix = .\\Scripts" "..\%project_name%\venv\pyvenv.cfg"
call .\bin\sed.exe -i "/base-exec-prefix = /c\base-exec-prefix = .\\Scripts" "..\%project_name%\venv\pyvenv.cfg"
call .\bin\sed.exe -i "/base-executable = /c\base-executable = .\\Scripts\\python.exe" "..\%project_name%\venv\pyvenv.cfg"



:: Copies ._pth config file to the project folder
call copy /Y ".\python-%python_version%\%pth_file%._pth" "..\%project_name%\venv\Scripts"

:: Re-edits the ._pth config file to enable relative import of core Python packages in the project folder
echo Lib/site-packages>..\%project_name%\venv\Scripts\%pth_file%._pth
echo ..\..\>>..\%project_name%\venv\Scripts\%pth_file%._pth
echo %pth_file%.zip>>..\%project_name%\venv\Scripts\%pth_file%._pth
echo .>>..\%project_name%\venv\Scripts\%pth_file%._pth
echo:>>..\%project_name%\venv\Scripts\%pth_file%._pth
echo # Uncomment to run site.main() automatically>>..\%project_name%\venv\Scripts\%pth_file%._pth
echo import site>>..\%project_name%\venv\Scripts\%pth_file%._pth



:: Deletes temporary 'sed' files
for %%f in (sed*.*) do (
	if "%%~xf" == "" (
		del %%~nxf
	)
)



:: Creates 'install' and 'run' project shortcuts
chdir ..\%project_name%

echo --prefer-binary>requirements.txt
echo:>>requirements.txt
:: echo streamlit>>requirements.txt

:: Install.bat
echo @echo off>install.bat
echo cls>>install.bat
echo call .\venv\Scripts\activate>>install.bat
echo call .\venv\Scripts\python.exe -m pip install -r requirements.txt>>install.bat
echo pause>>install.bat

:: Run.bat
:: echo @echo off>run.bat
:: echo cls>>run.bat
:: echo call .\venv\Scripts\activate>>run.bat
:: echo call .\venv\Scripts\streamlit.exe hello>>run.bat
:: echo pause>>run.bat
echo @echo off>run.bat
echo cls>>run.bat
echo call .\venv\Scripts\activate>>run.bat
echo call .\venv\Scripts\python.exe app.py>>run.bat
echo pause>>run.bat
echo print("Hello, Trully Portable Python!\n")>app.py



:: Exit
pause