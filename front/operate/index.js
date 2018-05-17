//时间转换页面
$(document).ready(function(){
  $("#login").click(function(){
  	var email = $('#email').val()
  	var password = $('#password').val()
  	if (email == null || password == null || email == "" || password == "") {
  		alert("用户名密码不能为空")
  		return
  	}
    $.ajax({
		type : "POST",
		url : "https://www.soaer.com/loginFilter",
		data : "email=" + email + "&password=" + password,
		success : function(msg) {
			if (msg.code == 1) {
				window.location.href="i";
			} else {
				$("#error").show()
			}
		}
	});
  });
});