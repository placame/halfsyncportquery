# halfsyncportquery
HalfSync Port Query Powershell script

## Description
Powershell script to scan remote TCP endpoints (host:port) in a really fast way.

Sometimes we have to check lots of remote endpoints if it accepts connection or can not be contacted.
Usually this task can be accomplished one by one by using the telnet command. Also there are tools to "scan remote ports" but those are binary executables. And as binary I'm not sure what they really do.
And of course to scan lots (more hundred) of endpoints takes really large amount of time, even if lots of them are closed and have to wait for the time-out.
So I decided to create a powershell script for this task. As it is a script, anybody can check and see what it really does. It uses async technique to make the scan faster. Also the script itself is working in sync mode, so it ends when all the scans completed. This dual behavior is why I called it "Half-Sync".

## Parameters
- HostNamePos            : the 0 based position of the hostname in each line of the Endpoint list
- PortPos                : the 0 based position of the port in each line of Endpoint list
- MaxNumberOfConnections : the maximum number of simultaneous connections to remote endpoints.
  Be avare changing this number as each connection requires local resources and a
  free source port.
- WaitMillisec           : the number of milliseconds the process will wait any time it needs to wait.
- Delimiter              : the delimiter used to separate fields in each line of endpoint list.
- AddHostname            : if specified, the resulting csv will contain the local host name in the first field as source.
- EndpointList           : name of the file holding the endpoint list.
- EndpointString         : a (probably multi lined) string holding the endpoint list (Like the content of a csv file)
- EndpointArray          : a string array holding the endpoint list (like the result of Get-Content commandlet)
- OutFile                : a filename or full path to save the result into it. (if omitted, the std-out will be used.)
- Append                 : if specified, the result will be appended to the end of the file.
