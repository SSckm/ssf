var formatJson = function(json, options) {
	var reg = null,
	formatted = '',
	pad = 0,
	PADDING = '    '; // one can also use '\t' or a different number of spaces
	// optional settings
	options = options || {};
	// remove newline where '{' or '[' follows ':'
	options.newlineAfterColonIfBeforeBraceOrBracket = (options.newlineAfterColonIfBeforeBraceOrBracket === true) ? true: false;
	// use a space after a colon
	options.spaceAfterColon = (options.spaceAfterColon === false) ? false: true;

	// begin formatting...
	// make sure we start with the JSON as a string
	if (typeof json !== 'string') {
		json = JSON.stringify(json);
	}
	// parse and stringify in order to remove extra whitespace
	json = JSON.parse(json);
	json = JSON.stringify(json);

	// add newline before and after curly braces
	reg = /([\{\}])/g;
	json = json.replace(reg, '\r\n$1\r\n');

	// add newline before and after square brackets
	reg = /([\[\]])/g;
	json = json.replace(reg, '\r\n$1\r\n');

	// add newline after comma
	reg = /(\,)/g;
	json = json.replace(reg, '$1\r\n');

	// remove multiple newlines
	reg = /(\r\n\r\n)/g;
	json = json.replace(reg, '\r\n');

	// remove newlines before commas
	reg = /\r\n\,/g;
	json = json.replace(reg, ',');

	// optional formatting...
	if (!options.newlineAfterColonIfBeforeBraceOrBracket) {
		reg = /\:\r\n\{/g;
		json = json.replace(reg, ':{');
		reg = /\:\r\n\[/g;
		json = json.replace(reg, ':[');
	}
	if (options.spaceAfterColon) {
		reg = /\:/g;
		json = json.replace(reg, ': ');
	}

	$.each(json.split('\r\n'),
	function(index, node) {
		var i = 0,
		indent = 0,
		padding = '';

		if (node.match(/\{$/) || node.match(/\[$/)) {
			indent = 1;
		} else if (node.match(/\}/) || node.match(/\]/)) {
			if (pad !== 0) {
				pad -= 1;
			}
		} else {
			indent = 0;
		}

		for (i = 0; i < pad; i++) {
			padding += PADDING;
		}

		formatted += padding + node + '\r\n';
		pad += indent;
	});

	return formatted;
};

function formatJsonVal() {
        $('#formaterErrorMsg').html("")
        var jsonVal, result, lineMatches;
        jsonVal = $('#tjson').val();
        try {
            result = validation.parser.parse(jsonVal);
            if(typeof JSON == 'object'){
                $('#tjson').val(JSON.stringify(JSON.parse(jsonVal), null, "    "))
            }else{
                $('#tjson').val( validation.format.formatJson(jsonVal) );
            }
            if (result) {
                $('#formaterErrorMsg').html("<font color=\"00ff00\"><h1>正确</h1></font>")
            } else {
                alert("未知错误");
            }
        } catch (parseException) {
            try {
                jsonVal = validation.format.formatJson($('#tjson').val());
                $('#tjson').val(jsonVal);
                result = validation.parser.parse($('#tjson').val());

            } catch(e) {
                parseException = e;
            }
            lineMatches = parseException.message.match(/line ([0-9]*)/);
            var j = parseInt(lineMatches[1]);
            $('#' + lineMatches[1]).html("<font color=\"#CC0000\">" + lineMatches[1] + "</font>")
            $('#' + (j + 1)).html("<font color=\"#CC0000\">" + (j + 1) + "</font>")
            $('#formaterErrorMsg').html("<font color=\"#FF0000\"><h1>" + lineMatches['input'] + "</h1></font>")
        }
    }
$(document).ready(function(){
  $("#transJson").click(function(){
    formatJsonVal();
  });
});

//MD5加密
$(document).ready(function(){
  $("#transMd5").click(function(){
    var old = $("#md5Before").val();
    if (old == "" || old == null) {
    	return;
    }
    var after = $.md5(old);
    $("#md5After").val(after)
  });
});

// URLEncode 加解密
$(document).ready(function(){
  $("#transUrlEncode").click(function(){
    var old = $("#encodeBefore").val();
    if (old == "" || old == null) {
    	return;
    }
    var after = encodeURI(old);
    $("#encodeAfter").val(after)
  });
});

$(document).ready(function(){
  $("#transUrlDecode").click(function(){
    var old = $("#encodeBefore").val();
    if (old == "" || old == null) {
    	return;
    }
    var after = decodeURI(old);
    $("#encodeAfter").val(after)
  });
});


// Base64加解密
$(document).ready(function(){
  $("#transBase").click(function(){
    $.base64.utf8encode = true;
    var old = $("#baseBefore").val();
    if (old == "" || old == null) {
    	return;
    }
    var after=$.base64.btoa(old)
    $("#baseAfter").val(after)
  });
});

$(document).ready(function(){
  $("#transBaseDecode").click(function(){
    $.base64.utf8decode = true;
    var old = $("#baseBefore").val();
    if (old == "" || old == null) {
    	return;
    }
    var after=$.base64.atob(old) 
    $("#baseAfter").val(after)
  });
});


//时间转换页面
$(document).ready(function(){
  $("#transDate").click(function(){
    var input = $("#dateBefore").val();
    var inLen = input.length
    var c = Number(input);
    if (isNaN(c) ) {
      //输入的不是时间戳
      input = input.replace("年", "-")
      input = input.replace("月", "-")
      input = input.replace("日", "-")
      input = input.replace("上午", "")
      input = input.replace("下午", "")
      input = input.replace("AM", "")
      input = input.replace("am", "")
      input = input.replace("PM", "")
      input = input.replace("pm", "")
      input = input.replace("a.m", "")
      input = input.replace("A.M", "")
      input = input.replace("p.m", "")
      input = input.replace("P.M", "")
      var timestamp2 = Date.parse(new Date(input));
      $("#dateAfter").html(timestamp2)
      return
    }
    var size = inLen - 13
    if (size <= 0) {
      var k = Math.abs(size)
      k = Math.pow(10,k)
      c = c * k
    } else {
      c = c/10^size
    }
    var newDate = new Date();
    newDate.setTime(c);
    var gmtDate = newDate.toGMTString()
    var iosDate = newDate.toISOString()
    var localDate = newDate.toLocaleString()
    var standDate = newDate.toString()
    var res = "时间戳:    " + c + "\r\n\r\n"
    res = res + "GMTDate(时区 + 8.00):     " + gmtDate + "\r\n\r\n" + "ISO Date(时区 + 8.00):      " + iosDate + "\r\n\r\n" + "本地时间(时区 + 0.00):      " + localDate + "\r\n\r\n" + "标准时间(时区 + 0.00):      " + standDate
    $("#dateAfter").html(res)
  });
});

function AES_CBC_NoPadding_Encrypt() {
    var aesInput = $("#aesBefore").val();
    var key = $("#aesKey").val();
    var iv = $("#aesIv").val();
    if (key == "" || iv == "") {
      alert("请输入密钥和IV")
      return;
    }

    // if (key.length != 16 || iv.length != 16) {
    //   alert("请输入16位的key和iv")
    //   return;
    // }
    key = CryptoJS.enc.Utf8.parse(key);
    iv  = CryptoJS.enc.Utf8.parse(iv);
    var encrypted = CryptoJS.AES.encrypt(aesInput, key,{
      iv : iv,
      mode : CryptoJS.mode.CBC,
      padding : CryptoJS.pad.ZeroPadding
    });
    $("#aesAfter").val(encrypted)
}

function AES_CBC_NoPadding_Decrypt() {
  var aesInput = $("#aesBefore").val();
    var key = $("#aesKey").val();
    var iv = $("#aesIv").val();
    if (key == "" || iv == "") {
      alert("请输入密钥和IV")
      return;
    }

    // if (key.length != 16 || iv.length != 16) {
    //   alert("请输入16位的key和iv")
    //   return;
    // }
    key = CryptoJS.enc.Utf8.parse(key);
    iv  = CryptoJS.enc.Utf8.parse(iv);
    var decrypted = CryptoJS.AES.decrypt(aesInput, key,{
      iv : iv,
      mode : CryptoJS.mode.CBC,
      padding : CryptoJS.pad.ZeroPadding
    });
    $("#aesAfter").val(decrypted.toString(CryptoJS.enc.Utf8))
}


function AES_ECB_PKCS5Padding_Encrypt() {
  var aesInput = $("#aesBefore").val();
    var key = $("#aesKey").val();
    if (key == "") {
      alert("请输入密钥")
      return;
    }
    // if (key.length != 16) {
    //   alert("密钥必须是16")
    //   return;
    // }
    key = CryptoJS.enc.Utf8.parse(key);
    var encrypted = CryptoJS.AES.encrypt(aesInput, key,{
      mode : CryptoJS.mode.ECB,
      padding : CryptoJS.pad.Pkcs7
    });
    $("#aesAfter").val(encrypted.toString())
}

function AES_ECB_PKCS5Padding_Decrypt() {
    var aesInput = $("#aesBefore").val();
    var key = $("#aesKey").val();
    if (key == "") {
      alert("请输入密钥和IV")
      return;
    }
    // if (key.length != 16) {
    //   alert("请输入16的密钥！")
    //   return;
    // }
    key = CryptoJS.enc.Utf8.parse(key);
    var decrypted = CryptoJS.AES.decrypt(aesInput, key,{
      mode : CryptoJS.mode.ECB,
      padding : CryptoJS.pad.Pkcs7
    });
    $("#aesAfter").val(decrypted.toString(CryptoJS.enc.Utf8))
}


function AES_CBC_PKCS7Padding_Encrypt() {
  var aesInput = $("#aesBefore").val();
    var key = $("#aesKey").val();
    var iv = $("#aesIv").val();
    if (key == "") {
      alert("请输入密钥")
      return;
    }
    // if (key.length != 16 || iv.length != 16) {
    //   alert("请输入16位的key和iv")
    //   return;
    // }
    key = CryptoJS.enc.Utf8.parse(key);
    iv = CryptoJS.enc.Utf8.parse(iv);
    var encrypted = CryptoJS.AES.encrypt(aesInput, key,{
      iv: iv,
      mode: CryptoJS.mode.CBC,
      padding:CryptoJS.pad.Pkcs7
    });
    $("#aesAfter").val(encrypted.toString())
}

function AES_CBC_PKCS7Padding_Decrypt() {
    var aesInput = $("#aesBefore").val();
    var key = $("#aesKey").val();
    var iv = $("#aesIv").val();
    if (key == "" || iv == "") {
      alert("请输入密钥和IV")
      return;
    }
    // if (key.length != 16 || iv.length != 16) {
    //   alert("请输入16位的key和iv")
    //   return;
    // }
    key = CryptoJS.enc.Utf8.parse(key);
    iv = CryptoJS.enc.Utf8.parse(iv);
    var decrypted = CryptoJS.AES.decrypt(aesInput, key,{
      iv: iv,
      mode : CryptoJS.mode.CBC,
      padding : CryptoJS.pad.Pkcs7
    });
    $("#aesAfter").val(decrypted.toString(CryptoJS.enc.Utf8))
}

$(document).ready(function(){
  $("#aesEncrypt").click(function(){
      var key = $("#aesKey").val();
      if (key == "" || key.length != 16 || key.length != 24 || key.length != 32) {
        alert("请输入正确长度的密钥！支持128bit/192bit/256bit")
        return;
      }
      var key = $("#cipherStyle").val()
      if (key == "1") {
        AES_CBC_NoPadding_Encrypt();
      } else if(key == "2") {
        AES_ECB_PKCS5Padding_Encrypt();
      } else if(key == "3") {
        AES_CBC_PKCS7Padding_Encrypt();
      }
  });
});

function changeBa() {
  var key = $("#cipherStyle").val()
  if (key == 2) {
    $("#aesIv").hide();
  } else {
    $("#aesIv").show();
  }
}

$(document).ready(function(){
  $("#aesDecrypt").click(function(){
      var key = $("#aesKey").val();
      if (key.length != 16 && key.length != 24 && key.length != 32) {
        alert("请输入正确长度的密钥！支持128bit/192bit/256bit")
        return;
      }
      var key = $("#cipherStyle").val()
      if (key == "1") {
        AES_CBC_NoPadding_Decrypt();
      } else if(key == "2") {
        AES_ECB_PKCS5Padding_Decrypt();
      } else if(key == "3") {
        AES_CBC_PKCS7Padding_Decrypt();
      }
  });  
});

$("#tjson").setTextareaCount({
  width: "30px",
  bgColor: "#999",
  color: "#FFF",
  display: "block"
});

function cctl() {
  $.ajax({
    type : "GET",
    url : "http://tool.soaer.com/c",
    success : function(msg) {
    }
  });
}

cctl()