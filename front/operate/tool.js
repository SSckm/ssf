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
  $("#transTime").click(function(){
    var old = $("#tjson").val();
    var newV = formatJson(old);
    $("#tjson").val(newV)
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