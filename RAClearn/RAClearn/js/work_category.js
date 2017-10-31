var preferredClassificationIndex = [
									{
											"occupationClassificationIndex":0,
											"occupationSubClassificationIndex":1,
											"occupationIndex":0
											
									},
									{
											"occupationClassificationIndex":1,
											"occupationSubClassificationIndex":0,
											"occupationIndex":0
											
									},
									{
										"occupationClassificationIndex":0,
										"occupationSubClassificationIndex":0,
										"occupationIndex":1
									},
									{
										"occupationClassificationIndex":1,
										"occupationSubClassificationIndex":1,
										"occupationIndex":0
									}
									];
var listClassification = [
		{
			"optClassificationId":"optClassificationId11",
			"optClassificationName":"农牧渔业",
			"subClassificationList":
			[
				{
					"optSubClassificationId":"optSubClassificationId12",
					"optSubClassificationName":"有毒动物饲养工",
					"occupationList":[
						{
							"occupationId":"id13",
							"occupationName":"蛇"
						},
						{
							"occupationId":"id13",
							"occupationName":"蝎子"
						},
						{
							"occupationId":"id13",
							"occupationName":"蜈蚣等"
						}
					]
				},
				{
					"optSubClassificationId":"optSubClassificationId12",
					"optSubClassificationName":"捕鱼人 ",
					"occupationList":[
						{
							"occupationId":"id13",
							"occupationName":"内陆"
						},
						{
							"occupationId":"id13",
							"occupationName":"沿海"
						}
					]
				}
				
			]
		},
		{
			"optClassificationId":"optClassificationId21",
			"optClassificationName":"交通运输业",
			"subClassificationList":
			[
				{
					"optSubClassificationId":"optSubClassificationId22",
					"optSubClassificationName":"陆运",
					"occupationList":[
						{
							"occupationId":"id23",
							"occupationName":"搬运工人"
						},
						{
							"occupationId":"id23",
							"occupationName":"装卸工人"
						}
					]
				},
				{
					"optSubClassificationId":"optSubClassificationId22",
					"optSubClassificationName":"海运",
					"occupationList":[
						{
							"occupationId":"id23",
							"occupationName":"船员"
						},
						{
							"occupationId":"id23",
							"occupationName":"就难人员"
						}
					]
				}
				
			]
		},
		{
			"optClassificationId":"optClassificationId21",
			"optClassificationName":"建筑工程",
			"subClassificationList":
			[
				{
					"optSubClassificationId":"optSubClassificationId22",
					"optSubClassificationName":"建筑公司",
					"occupationList":[
						{
							"occupationId":"id23",
							"occupationName":"钢骨结构"
						},
						{
							"occupationId":"id23",
							"occupationName":"铁工"
						}
					]
				},
				{
					"optSubClassificationId":"optSubClassificationId22",
					"optSubClassificationName":"测绘工程",
					"occupationList":[
						{
							"occupationId":"id23",
							"occupationName":"铺设工人"
						},
						{
							"occupationId":"id23",
							"occupationName":"维护工人"
						}
					]
				}
				
			]
		}
		
];
var currentIndex = {
	"occupationClassificationIndex":-1,
	"occupationSubClassificationIndex":-1,
	"occupationIndex":-1
};

var currentJob = {
	"optClassificationId":"",
	"optClassificationName":"",
	"optSubClassificationId":"",
	"optSubClassificationName":"",
	"occupationId":"",
	"occupationName":""
};

onload=function(){
	showDialog();
	setTimeout(function(){
			dismissDialog();
				showError();
			
			setTimeout(function(){
				hideError();
				initNav();
				initSection();
				initListener();
			},1000);
	},1000);
}
var commonJob;
var secContainer;

function initNav(){
	var nav = document.getElementById("nav");
	nav.style.display = preferredClassificationIndex.length>0?"block":"none";
	if(preferredClassificationIndex.length>0){
		commonJob = nav.getElementsByClassName("common-job")[0];
		for(var i=0;i<preferredClassificationIndex.length/3;i++){
			var ul = document.createElement("ul");	
			for(var j=0;j<3&&(i*3+j)<preferredClassificationIndex.length;j++){
				var index = i*3+j;
				var nodeIndex = preferredClassificationIndex[index];
				var li = document.createElement("li");
				li.setAttribute("class","common-item");
				li.innerText = ""+listClassification[nodeIndex.occupationClassificationIndex].subClassificationList[nodeIndex.occupationSubClassificationIndex].occupationList[nodeIndex.occupationIndex].occupationName;
				li.occupationClassificationIndex = nodeIndex.occupationClassificationIndex;
				li.occupationSubClassificationIndex=nodeIndex.occupationSubClassificationIndex;
				li.occupationIndex = nodeIndex.occupationIndex;
				ul.appendChild(li);
			}
			commonJob.appendChild(ul);
		}
	}
}

function initSection(){
	var topClassCount = listClassification.length;
	secContainer = document.getElementsByClassName("sections")[0];
	for(var i = 0;i<listClassification.length;i++){
		var secItem = document.createElement("section");
		secItem.setAttribute("class","section-item");
		
		var top = listClassification[i];
		var topItem = document.createElement("div");
		topItem.setAttribute("class","item-top");
		topItem.innerHTML='<div >'+top.optClassificationName+'</div>'+'<img src="img/ic_setting_view_arrow.png" alt="" class="row"/>';
		topItem.optClassificationId = top.optClassificationId;
		topItem.optClassificationName = top.optClassificationName;
		secItem.appendChild(topItem);
		
		var midList = top.subClassificationList;
		for(var j= 0;j<midList.length;j++){
			var mid = midList[j];
			var midItem = document.createElement("div");
			midItem.setAttribute("class","item-mid");
			midItem.optSubClassificationName=mid.optSubClassificationName;
			midItem.optSubClassificationId = mid.optSubClassificationId;
			
			var detailList = mid.occupationList;
			for(var k = 0;k<detailList.length;k++){
				var detail = detailList[k];
				var detailDiv = document.createElement("div");
				detailDiv.setAttribute("class","item-inner");
				detailDiv.innerText =mid.optSubClassificationName+":"+detail.occupationName;
				detailDiv.occupationId=detail.occupationId;
				detailDiv.occupationName = detail.occupationName;
				
				
				detailDiv.occupationClassificationIndex = i;
				detailDiv.occupationSubClassificationIndex= j;
				detailDiv.occupationIndex = k;
			
				midItem.appendChild(detailDiv);
			}
			
			secItem.appendChild(midItem);
		}

		
		secContainer.appendChild(secItem);
	}
	
}

function initListener(){
	//上方的推荐列表
	var liArray = commonJob.getElementsByClassName("common-item");
	var secArray = secContainer.getElementsByClassName("item-top");
	
	for(var i = 0;i<liArray.length;i++){
		liArray[i].index = i;
		liArray[i].onclick = function(){
			for(var j = 0;j<liArray.length;j++){
				liArray[j].style.border="1px solid #D9D9D9";
				liArray[j].style.color="#999999";
			}
			liArray[this.index].style.border="1px solid #4945B7";
			liArray[this.index].style.color="#4945B7";
			sync(this.occupationClassificationIndex, this.occupationSubClassificationIndex,this.occupationIndex);
			performClick(this.occupationClassificationIndex, this.occupationSubClassificationIndex,this.occupationIndex);
		}
	}
	
	//展开Item
	for(var j =0;j<secArray.length;j++){
		secArray[j].index = j;
		secArray[j].onclick = function(){
			
			for(var k = 0;k<secArray.length;k++){
				var midItems = secArray[k].parentNode.getElementsByClassName("item-mid");
				var row = secArray[k].getElementsByClassName("row")[0];
				row.classList.remove("row-choose");
				row.classList.add("row-normal");
				for(var item = 0;item<midItems.length;item++){
					midItems[item].style.display = "none";
				}
			}
			
			if(this.parentNode.parentNode.openIndex === this.index && this.openStats){
				this.openStats = false;
				return;
			}
			var row = secArray[this.index].getElementsByClassName("row")[0];
			row.classList.remove("row-normal");
			row.classList.add("row-choose");
			var midItems = secArray[this.index].parentNode.getElementsByClassName("item-mid");
			for(var item = 0;item<midItems.length;item++){
				midItems[item].style.display = "block";
			}
			this.parentNode.parentNode.openIndex=this.index;
			this.openStats = true;
		}
	}
	
	//下方的小职业选择
	var itemsArray = secContainer.getElementsByClassName("item-inner");
	for(var inner = 0;inner<itemsArray.length;inner++){
		itemsArray[inner].index = inner;
		itemsArray[inner].onclick = function(){
			for(var innerIndex = 0;innerIndex<itemsArray.length;innerIndex++){
				itemsArray[innerIndex].style.color = "#999999";
			}
			itemsArray[this.index].style.color = "#4945B7";
			sync(this.occupationClassificationIndex,this.occupationSubClassificationIndex,this.occupationIndex);
		}
	}
}

function sync(topIndex,subIndex,occuIndex){
	var index = -1;
	for(var i = 0;i<preferredClassificationIndex.length;i++){
		var info = preferredClassificationIndex[i];
		if(info.occupationClassificationIndex===topIndex&&info.occupationSubClassificationIndex == subIndex && info.occupationIndex==occuIndex){
			index = i;
			break;
		}
	}	
	var commonItems = commonJob.getElementsByClassName("common-item");
	for(var i = 0;i<commonItems.length;i++){
		commonItems[i].style.border = "1px solid #D9D9D9";
		commonItems[i].style.color = "#999999";
	}
	if(index >=0){
		commonItems[index].style.border="1px solid #4945B7";
		commonItems[index].style.color="#4945B7";
	}
	
	
	currentJob.optClassificationId = listClassification[topIndex].optClassificationId;
	currentJob.optClassificationName = listClassification[topIndex].optClassificationName;
	var subClassificationList = listClassification[topIndex].subClassificationList;
	currentJob.optSubClassificationId = subClassificationList[subIndex].optSubClassificationId;
	currentJob.optSubClassificationName = subClassificationList[subIndex].optSubClassificationName;
	var occupationList = subClassificationList[subIndex].occupationList;
	currentJob.occupationId = occupationList[occuIndex].occupationId;
	currentJob.occupationName = occupationList[occuIndex].occupationName;
	
	console.log(currentJob);
}

function performClick(topIndex,subIndex,occuIndex){
	if(currentIndex.occupationClassificationIndex == topIndex 
		&& currentIndex.occupationSubClassificationIndex == subIndex
		&& currentIndex.occupationIndex == occuIndex)
	{
		console.log("prevent");
		console.log(currentIndex);
		return;
	}
	currentIndex.occupationClassificationIndex = topIndex;
	currentIndex.occupationSubClassificationIndex = subIndex;
	currentIndex.occupationIndex = occuIndex;
	
	var secArray = secContainer.getElementsByClassName("item-top");
	var ev = new MouseEvent('click', {
	         cancelable: true,
    	     bubble: true,
        	 view: window,
     	});
    secArray[topIndex].dispatchEvent(ev);
    var midClass = secArray[topIndex].parentNode.getElementsByClassName("item-mid")[subIndex];
	var occu = midClass.getElementsByClassName("item-inner")[occuIndex]; 
	occu.dispatchEvent(ev);
}

function dismissDialog(){
	var mask = document.getElementsByClassName("mask");
	mask[0].style.display = "none";
}

function showDialog(){
	var mask = document.getElementsByClassName("mask");
	mask[0].style.display = "block";
}

function showError(){
	var errorDiv = document.querySelector(".net-error");
	errorDiv.style.display = "block";
}

function hideError(){
		var errorDiv = document.querySelector(".net-error");
		errorDiv.style.display = "none";
}
