# halfsyncportquery
HalfSync Port Query Powershell script


Powershell script to scan remote TCP endpoints (host:port) in a really fast way.

Sometimes we have to check lots of remote endpoints if it accepts connection or can not be contacted.
Usually this task can be accomplished one by one by using the telnet command. Also there are tools to "scan remote ports" but those are binary executables. And as binary I'm not sure what they really do.
And of course to scan lots (more hundred) of endpoints takes really large amount of time, even if lots of them are closed and have to wait for the time-out.
So I decided to create a powershell script for this task. As it is a script, anybody can check and see what it really does. It uses async technique to make the scan faster. Also the script itself is working in sync mode, so it ends when all the scans completed. This dual behavior is why I called it "Half-Sync".
