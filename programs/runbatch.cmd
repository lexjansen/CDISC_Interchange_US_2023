@echo off
set SAScmd="C:\Program Files\SASHome\SASFoundation\9.4\sas.exe" -ls 200 -ps 60 -nocenter -nosplash -sysin
set SASconfig=-nologo -config "C:\Program Files\SASHome\SASFoundation\9.4\nls\u8\SASV9.CFG"

cd ..\programs

for %%i in (log html xlsx lst) do @if exist *.%%i del *.%%i
if exist runbatch*.txt del runbatch*.txt
if exist ..\definexml\define_sdtm_3.3_vlm.* del ..\definexml\define_sdtm_3.3_vlm.*
if exist ..\data\*.html del ..\data\*.html
if exist ..\data\*.xlsx del ..\data\*.xlsx
if exist ..\data\*.sas7* del ..\data\*.sas7*
if exist ..\metadata\*.sas7* del ..\metadata\*.sas7*

%SAScmd% 00_define_study_standards.sas %SASconfig%
%SAScmd% 01_request_api_bc_RECIST.sas %SASconfig%
%SAScmd% 01_request_api_sdtm_specs_RS_TR_TU.sas %SASconfig%
%SAScmd% 02_request_api_sdtm_domains.sas %SASconfig%
%SAScmd% 03_create_vlm_from_sdtm_specializations.sas %SASconfig%
%SAScmd% 04_request_api_ct.sas %SASconfig%
%SAScmd% 05_create_ct_metadata.sas %SASconfig%
%SAScmd% 06_create_definexml.sas %SASconfig%

findstr /i /n /r /g:C:\tools\ultraedit-configuration\search.txt "*.log" | findstr /i /v /g:C:\tools\ultraedit-configuration\search_not.txt > %~n0.log

type runbatch.log

if exist \_projects\xml_validate_schema_schematron\xml\define_sdtm_3.3_vlm.xml del \_projects\xml_validate_schema_schematron\xml\define_sdtm_3.3_vlm.xml
copy ..\definexml\*.xml \_projects\xml_validate_schema_schematron\xml

pushd \_projects\xml_validate_schema_schematron\program

call validate_xml_schema_schematron-21.cmd ..\xml define_sdtm_3.3_vlm.xml ..\xsl\define2-1.xsl ..\results define

popd
copy \_projects\xml_validate_schema_schematron\results\*result*.html ..\definexml


PING localhost -n 5 >NUL
