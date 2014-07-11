function toushi()
{
	//alert("huweitest");
	var tg3d = document.getElementById("DCQocx1");
	tg3d.SendCommand("OnQuyutongshi",6);
}
function wafang()
{
	var tg3d = document.getElementById("DCQocx1");
	tg3d.SendCommand("OnQueryVolume",6);
}
function pathAnalyse()
{
	var tg3d = document.getElementById("DCQocx1");
	tg3d.SendCommand("OnPathTool",6);
}
function getFlashIDtest()
{
	var test = document.getElementById("HZ2D_3D");
	test.test1();
}
function getC3Dwidth(arr)
{
	var tg3d = document.getElementById("DCQocx1");
	tg3d.width = arr[0];
	tg3d.height=arr[1];
	//alert("huweitest");
}
function drawSymbol()
{
	//alert("hsjdfklw123123123");
	var tg3d = document.getElementById("DCQocx1");
	tg3d.SendCommand("FlyTo,116.3078,39.9072,aaaa", 6);
	tg3d.DrawMPointJW("xxxx", 116.3109, 39.9072, 70, 0, 0, 4444, 600000, 103, "volcano.png",  "lll", 344325, 1, 0, 0);
	tg3d.DrawMPointJW("xxxx", 116.3117, 39.9072, 70, 0, 0, 4444, 600000, 104, "volcano.png",  "lhuwei", 344325, 1, 0, 0);
	//tg3d.DrawMPointJW("xxxx", 116.3109, 39.9072, 70, 0, 0, 4444, 600000, 103, "water.png",  "123123123", 344325, 1, 0, 0);
	//tg3d.DrawMPointJW("xxxx", 116.3117, 39.9072, 70, 0, 0, 4444, 600000, 104, "water.png",  "lhuwei", 344325, 1, 0, 0);
	//tg3d.SendCommand("RemovePicture,xxxx,103", 6);
	
}
function removeSymbol()
{
	var tg3d = document.getElementById("DCQocx1");
	tg3d.SendCommand("RemovePicture,xxxx,103", 6);
}
