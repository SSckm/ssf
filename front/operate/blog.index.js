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
                                                    "<a href=\"http://blog.soaer.com/"+ uid + "/" + htmlId + ".html" +"\">" + title + "</a>" + 
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
		url : "http://blog.soaer.com/s",
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




function initList(msg) {
	var blogArray = msg.list
	if (blogArray == null || blogArray.length == 0) {
		return;
	}

	for (var i = 0; i < blogArray.length; i++) {
		var authId = blogArray[i].createUserId
		var title = blogArray[i].title
		var blogKey = blogArray[i].htmlFileId
		var content = blogArray[i].content
		var date = blogArray[i].createDate
		$('#b'+ (i + 1)).attr('href','http://blog.soaer.com/' + authId + "/" + blogKey + ".html"); 
		$('#b'+ (i + 1)).text(title);
		$('#p'+ (i + 1)).text(content);
		$('#d'+ (i + 1)).text(date);
		$('#img'+ (i + 1)).attr('href','http://blog.soaer.com/' + authId + "/" + blogKey + ".html"); 
	}
}


function init() {
	$.ajax({
		type : "POST",
		url : "http://blog.soaer.com/gbl",
		data : "pageNumber=1",
		success : function(msg) {
			if (msg.code == 1) {
				initList(msg);
			}
		}
	});
}


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
    url : "http://blog.soaer.com/ci",
    success : function(msg) {
    }
  });
}

ci()

$(document).ready(function(){
	init();
});