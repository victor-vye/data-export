/* Reference the uploaded JSON data; */
filename indata filesrvc "&_WEBIN_FILEURI";
libname indata json;
/* Assign the export filename to write the response for the job; */
filename export filesrvc parenturi="&SYS_JES_JOB_URI" name='_export.txt';

/* Generate macro for the filter expression and the CAS library and table */
proc sql noprint;
	select scan(value,1,'.'), scan(value,2,'.')
        into :caslib, :castab
    from indata.filters
    where label ="Source Table";
	select case when operator = "in" or dataType = "number" then catx(' ', label, operator, value)
            else catx(' ',label, operator, quote(trim(value))) end as filter
        into : filterValues separated by " and "
    from indata.filters
    where label ne "Source Table";
quit;

/* Connect to CAS and assign the libraries */
cas mySess;
libname cassrc cas caslib="&caslib" ;

/* Define list of variables */
proc sql noprint;
	select name
        into : columnList separated by ', '
        from sashelp.vcolumn
        where libname = "CASSRC"
        and memname= upcase("&casTab")
        and (label in (select label from indata.columns) or name in (select label from indata.columns) );
quit;

/* Create the export table based on the filter */
proc sql;
create table export as select &columnList from cassrc.&castab where &filterValues;
quit;

/* Create the export file */
proc export data=export outfile=export dbms=tab;
run;

/* Write information about the export file for UI consumption */
proc json out=_webout pretty nosastags;
	write open object ;
    write values "resultFile";
    write values "&_FILESRVC_export_URI";
    write close;
run;
quit;


