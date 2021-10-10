param(
[int]$HostNamePos=1,
[int]$PortPos=2,
[int]$MaxNumberOfConnections=500,
[int]$WaitMillisec=100,
[string]$Delimiter=";",
[switch]$AddHostname,
[string]$EndpointList="",
[string]$EndpointString="",
[string[]]$EndpointArray,
[string]$OutFile,
[switch]$Append)
# Parameters above: HostNamePos            : the 0 based position of the hostname in each line of the Endpoint list
#                   PortPos                : the 0 based position of the port in each line of Endpoint list
#                   MaxNumberOfConnections : the maximum number of simultaneous connections to remote endpoints.
#                                                Be avare changing this number as each connection requires local resources and a
#                                                free source port.
#                   WaitMillisec           : the number of milliseconds the process will wait any time it needs to wait.
#                   Delimiter              : the delimiter used to separate fields in each line of endpoint list.
#                   AddHostname            : if specified, the resulting csv will contain the local host name in the first field as source.
#                   EndpointList           : name of the file holding the endpoint list.
#                   EndpointString         : a (probably multi lined) string holding the endpoint list (Like the content of a csv file)
#                   EndpointArray          : a string array holding the endpoint list (like the result of Get-Content commandlet)
#                   OutFile                : a filename or full path to save the result into it. (if omitted, the std-out will be used.)
#                   Append                 : if specified, the result will be appended to the end of the file.
add-type -type  @'
using System;
using System.Net.Sockets;
using System.Net;
using System.Threading;
namespace PortQry
{
    public class Qry
    {
        static Mutex mxActionThreads = new Mutex(false);
        private int numOfThreads;
        public int myNumberOfThreads { get { return this.numOfThreads; } }
        static Mutex mxResult = new Mutex(false);
        private string myResult;
        public string ResultStr { get { return this.myResult; } }

        public Qry() { numOfThreads = 0;myResult=""; }

        public void Result(IAsyncResult result)
			{
            mxActionThreads.WaitOne();
            numOfThreads -= 1;
            mxActionThreads.ReleaseMutex();
			try
			{
			Socket s = (Socket)(((object[])(result.AsyncState))[0]);
			string i = (string)(((object[])(result.AsyncState))[1]);
			string delimiter = (string)(((object[])(result.AsyncState))[2]);
			mxResult.WaitOne();
			if(s.Connected)
				myResult+=i+delimiter+"OPEN\r\n";
			else
				myResult+=i+delimiter+"closed\r\n";
			mxResult.ReleaseMutex();
			}
			catch 
			{
			}
			}
        public void Test(string hn,int port, string info,string delimiter)
			{
			AsyncCallback callBack = new AsyncCallback(Result);
			Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
			object[] ts= new object[] {s,info,delimiter};
			try {
				s.BeginConnect(Dns.GetHostAddresses(hn), port, callBack, ts);
				mxActionThreads.WaitOne();
				numOfThreads += 1;
				mxActionThreads.ReleaseMutex();
			} catch (Exception e) 
				{
				mxResult.WaitOne(); 
				myResult+=info+delimiter+"Error:"+e.Message+"\r\n"; 
				mxResult.ReleaseMutex();
				}
			}
    }
}
'@
if(!$EndpointArray){
if($EndpointString){$EndpointArray="$EndpointString".replace("`r","").split("`n")}
if($EndpointList){$EndpointArray=get-content $EndpointList}
}
if(!$MyPortQuery){$MyPortQuery=new-object PortQry.Qry;}
$EndpointArray|%{
  if($_){
    $myInfo=$_;
    if($AddHostName){$myInfo="$($env:computername)$Delimiter$_"}
    $myHost=$_.split($Delimiter)[$HostNamePos]
    $myPort=$_.split($Delimiter)[$PortPos]
    while($myportquery.mynumberofthreads -gt $MaxNumberOfConnections){sleep -Milliseconds $WaitMillisec;}
    $MyPortQuery.Test($myHost,$myPort,$myInfo,$Delimiter)
}}
while($myportquery.mynumberofthreads -gt 0){sleep -Milliseconds $WaitMillisec;}
$MyResult=$myportquery.ResultStr;
if($MyResult){$MyResult=$MyResult.SubString(0,$MyResult.Length-2)}
if($OutFile){
	if($Append){
		$MyResult|Out-File $OutFile -Force -Append
	}else{
		$MyResult|Out-File $OutFile -Force}
}else{
	$MyResult;
}