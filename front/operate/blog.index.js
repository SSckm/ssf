function addLiTag(blogArray) {
	for (var i = 0; i < blogArray.length; i++) {
		var date = blogArray[i].createDate
		var dateStmp = new Date(date);
		var year = dateStmp.getFullYear();
		var month = dateStmp.getMonth() + 1;
		var day = dateStmp.getDate();
		var title = blogArray[i].title
		var content = blogArray[i].content
		var uid = blogArray[i].createUserId
		var htmlId = blogArray[i].htmlFileId
		var tagsArray = blogArray[i].tags
		var tagStr = "<a href=\"javascript:;\" class=\"btn btn-circle yellow disabled\">标签</a>"
		if (tagsArray != null && tagsArray.length >= 1) {
			for (var j = 0; j < tagsArray.length; j++) {
				tagStr = tagStr + "<a href=\"\" class=\"btn btn-circle green disabled\">" + tagsArray[j].name + "</a>"
			}
		}
		tagStr = tagStr + "<a href=\"javascript:;\" class=\"btn btn-circle white disabled\">" + date + "</a>"
		$("#search-container-list")
				.append("<li class=\"search-item clearfix\">" +
                                            "<div class=\"search-content text-left\">" +
                                                "<h2 class=\"search-title\">" +
                                                    "<a href=\"https://blog.soaer.com/"+ uid + "/" + htmlId + ".html" +"\">" + title + "</a>" + 
                                                "</h2>" + 
                                                "<p class=\"search-desc\">" + content + "</p>" +
                                            "</div>" + 
                                            "<div class=\"noteAd\">" + 
                                            "<br />" + 
                                            tagStr +
                                            "</div>" +
                                        "</li>");
	}
}


function insertBlogList(msg, isLoadMore) {
	var blogArray = msg.list
	if (blogArray == null || blogArray.length == 0) {
		if (!isLoadMore) {
			$('#showBlogs li').remove();
			$("#search-container-list").append("<li>无数据</li>")
			$("#loadMore").hide()
			$("#showBlogs").show()
		}
		return;
	}
	var totalCount = msg.total

	//是否显示加载更多按钮
	var pageNumber = $('#pageNumber').val();
	if (pageNumber * 10 < totalCount) {
		$("#loadMore").show()
	} else {
		$("#loadMore").hide()
	}

	$("#showBlogs").show()
	addLiTag(blogArray);
}


function sl(isLoadMore) {
	if (!isLoadMore) {
		$('#pageNumber').val("1")
	}
	$("#initBlogIndex").hide()
	var obj = $('#searchWord').val();
	if (obj == null) {
		return;
	}

	var g = $.trim(obj)
	if (g == "") {
		return;
	}

	if (g.length > 30) {
		alert("搜索内容过长,最多30个字！")
		return;
	}
	var pageNumber = $('#pageNumber').val();
	if (pageNumber == "" || pageNumber == null) {
		pageNumber = 1
		$('#pageNumber').val("1")
	}
	if (isLoadMore) {
		var j = parseInt(pageNumber);
		pageNumber = j + 1;
		$('#pageNumber').val(pageNumber)
	}

	$.ajax({
		type : "POST",
		url : "https://blog.soaer.com/skw",
		data : "keyWord=" + obj + "&pageNumber=" + pageNumber,
		success : function(msg) {
			if (msg.code == 1) {
				if (!isLoadMore) {
					$('#showBlogs li').remove();
				}
				insertBlogList(msg, isLoadMore)
			}
		}
	});
}

function addNextPage(blogArray) {
	for (var i = 0; i < blogArray.length; i++) {
		var date = blogArray[i].createDate
		var dateStmp = new Date(date);
		var year = dateStmp.getFullYear();
		var month = dateStmp.getMonth() + 1;
		var day = dateStmp.getDate();
		var title = blogArray[i].title
		var content = blogArray[i].content
		var uid = blogArray[i].createUserId
		var htmlId = blogArray[i].htmlFileId
		var tagsArray = blogArray[i].tags
		var body = "<div class=\"timeline-item\">" +
			"<div class=\"timeline-badge\">" +
				"<div class=\"timeline-icon\">"+
					"<i class=\"icon-docs font-red-intense\"></i>"+
				"</div>"+
			"</div>"+
			"<div class=\"timeline-body\">"+
				"<div class=\"timeline-body-arrow\"></div>"+
				"<div class=\"timeline-body-head\">"+
					"<div class=\"timeline-body-head-caption\">"+
						"<a "+
							"href=\"https://blog.soaer.com/" + uid + "/" + htmlId + ".html\"><span "+
							"class=\"timeline-body-alerttitle font-green-haze\">" + title + "</span></a>"+
					"</div>"+
				"</div>"+
				"<div class=\"timeline-body-content\">"+
					"<span class=\"font-grey-cascade\">"+
						content + 
					"</span>"+
				"</div>"+
			"</div>"+
		"</div>"
		$("#blogNext").append(body);
	}
}


function parseNextPage(msg) {
	var blogArray = msg.list
	if (blogArray == null || blogArray.length == 0) {
		return;
	}
	var totalCount = msg.total
	var pageNumber = $('#findPageNumber').val();
	var j = parseInt(pageNumber);
	if (j * 10 > totalCount) {
		$("#findNextPage").hide()
		$("#noBlogs").show()
	}
	addNextPage(blogArray);
}


$(document).ready(function(){
	$("#findNextPage").click(function(){
		var findPageNumber = $('#findPageNumber').val();
		if (findPageNumber == "" || findPageNumber == null) {
			findPageNumber = 1
			$('#findPageNumber').val("1")
		}
		var j = parseInt(findPageNumber);
		findPageNumber = j + 1;
		$('#findPageNumber').val(findPageNumber)
		$.ajax({
			type : "POST",
			url : "https://blog.soaer.com/gnp",
			data : "pageNumber=" + findPageNumber,
			success : function(msg) {
				if (msg.code == 1) {
					parseNextPage(msg)
				}
			}
		});
  	});
});


$(document).ready(function(){
	$("#search").click(function(){
		sl(false);
  	});
  	var obj = $('#searchWord').val();
	if (obj == null || obj == "") {
		return;
	}
	sl(false);
});

function ci() {
  $.ajax({
    type : "GET",
    url : "https://blog.soaer.com/ci",
    success : function(msg) {
    }
  });
}
ci()