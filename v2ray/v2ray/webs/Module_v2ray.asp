<title>V2Ray</title>
<content>
<script type="text/javascript" src="/js/jquery.min.js"></script>
<script type="text/javascript" src="/js/tomato.js"></script>
<script type="text/javascript" src="/js/advancedtomato.js"></script>
<style type="text/css">
.box {
	min-width:540px;
}
</style>
	<script type="text/javascript">
		var dbus;
		get_arp_list();
		get_dbus_data();
		var _responseLen;
		var noChange = 0;
		var x = 4;
		var status_time = 1;
		var option_mode = [['VMess', 'VMess']];
		var option_acl_mode = [['0', '不代理'], ['1', 'gfwlist黑名单'], ['2', '大陆白名单'], ['3', '游戏模式'], ['4', '全局模式']];
		var option_auth = [['none', '不加密'], ['auto', '自动'], ['aes-128-cfb', 'aes-128-cfb'], ['aes-128-gcm', 'aes-128-gcm'], ['chacha20-poly1305', 'chacha20-poly1305']];
		//var option_transport = [['tcp', 'tcp'], ['kcp', 'kcp'], ['ws', 'ws']];
		var option_acl_mode_name = ['不代理', 'gfwlist黑名单', '大陆白名单', '游戏模式', '全局模式'];
		var option_dns_china = [['1', '运营商DNS【自动获取】'],  ['2', '阿里DNS1【223.5.5.5】'],  ['3', '阿里DNS2【223.6.6.6】'],  ['4', '114DNS1【114.114.114.114】'],  
								['5', '114DNS1【114.114.115.115】'],  ['6', 'cnnic DNS【1.2.4.8】'],  ['7', 'cnnic DNS【210.2.4.8】'],  ['8', 'oneDNS1【112.124.47.27】'],  
								['9', 'oneDNS2【114.215.126.16】'],  ['10', '百度DNS【180.76.76.76】'],  ['11', 'DNSpod DNS【119.29.29.29】'],  ['12', '自定义']];
		var option_v2ray_dns_foreign = [['2', 'google dns\[8.8.8.8\]'], ['3', 'google dns\[8.8.4.4\]'], ['1', 'OpenDNS\[208.67.220.220\]'], ['4', '自定义']];
		var option_dns_foreign = [['1', 'v2ray_dns']];
		var option_arp_list = [];
		var option_arp_local = [];
		var option_arp_web = [];
		var softcenter = 0;

		if (typeof btoa == "Function") {
			Base64 = {
				encode: function(e) {
					return btoa(e);
				},
				decode: function(e) {
					return atob(e);
				}
			};
		} else {
			Base64 = {
				_keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
				encode: function(e) {
					var t = "";
					var n, r, i, s, o, u, a;
					var f = 0;
					e = Base64._utf8_encode(e);
					while (f < e.length) {
						n = e.charCodeAt(f++);
						r = e.charCodeAt(f++);
						i = e.charCodeAt(f++);
						s = n >> 2;
						o = (n & 3) << 4 | r >> 4;
						u = (r & 15) << 2 | i >> 6;
						a = i & 63;
						if (isNaN(r)) {
							u = a = 64
						} else if (isNaN(i)) {
							a = 64
						}
						t = t + this._keyStr.charAt(s) + this._keyStr.charAt(o) + this._keyStr.charAt(u) + this._keyStr.charAt(a)
					}
					return t
				},
				decode: function(e) {
					var t = "";
					var n, r, i;
					var s, o, u, a;
					var f = 0;
					if (typeof(e) == "undefined"){
						return t = "";
					}
					e = e.replace(/[^A-Za-z0-9\+\/\=]/g, "");
					while (f < e.length) {
						s = this._keyStr.indexOf(e.charAt(f++));
						o = this._keyStr.indexOf(e.charAt(f++));
						u = this._keyStr.indexOf(e.charAt(f++));
						a = this._keyStr.indexOf(e.charAt(f++));
						n = s << 2 | o >> 4;
						r = (o & 15) << 4 | u >> 2;
						i = (u & 3) << 6 | a;
						t = t + String.fromCharCode(n);
						if (u != 64) {
							t = t + String.fromCharCode(r)
						}
						if (a != 64) {
							t = t + String.fromCharCode(i)
						}
					}
					t = Base64._utf8_decode(t);
					return t
				},
				_utf8_encode: function(e) {
					e = e.replace(/\r\n/g, "\n");
					var t = "";
					for (var n = 0; n < e.length; n++) {
						var r = e.charCodeAt(n);
						if (r < 128) {
							t += String.fromCharCode(r)
						} else if (r > 127 && r < 2048) {
							t += String.fromCharCode(r >> 6 | 192);
							t += String.fromCharCode(r & 63 | 128)
						} else {
							t += String.fromCharCode(r >> 12 | 224);
							t += String.fromCharCode(r >> 6 & 63 | 128);
							t += String.fromCharCode(r & 63 | 128)
						}
					}
					return t
				},
				_utf8_decode: function(e) {
					var t = "";
					var n = 0;
					var r = c1 = c2 = 0;
					while (n < e.length) {
						r = e.charCodeAt(n);
						if (r < 128) {
							t += String.fromCharCode(r);
							n++
						} else if (r > 191 && r < 224) {
							c2 = e.charCodeAt(n + 1);
							t += String.fromCharCode((r & 31) << 6 | c2 & 63);
							n += 2
						} else {
							c2 = e.charCodeAt(n + 1);
							c3 = e.charCodeAt(n + 2);
							t += String.fromCharCode((r & 15) << 12 | (c2 & 63) << 6 | c3 & 63);
							n += 3
						}
					}
					return t
				}
			}
		}
		//============================================
		var v2ray_acl = new TomatoGrid();
		v2ray_acl.dataToView = function( data ) {
			if (data[0]){
				return [ "【" + data[0] + "】", data[1], data[2], option_acl_mode_name[data[3]] ];
			}else{
				if (data[1]){
					return [ "【" + data[1] + "】", data[1], data[2], option_acl_mode_name[data[3]]];
				}else{
					if (data[2]){
						return [ "【" + data[2] + "】", data[1], data[2], option_acl_mode_name[data[3]] ];
					}
				}
			}
		}
		v2ray_acl.fieldValuesToData = function( row ) {
			var f = fields.getAll( row );
			if (f[0].value){
				return [ f[0].value, f[1].value, f[2].value, f[3].value ];
			}else{
				if (f[1].value){
					return [ f[1].value, f[1].value, f[2].value, f[3].value ];
				}else{
					if (f[2].value){
						return [ f[2].value, f[1].value, f[2].value, f[3].value ];
					}
				}
			}
		}
    	v2ray_acl.onChange = function(which, cell) {
    	    return this.verifyFields((which == 'new') ? this.newEditor: this.editor, true, cell);
    	}
		v2ray_acl.verifyFields = function( row, quiet,cell ) {
			var f = fields.getAll( row );
			// fill the ip and mac when chose the name
			if ( $(cell).attr("id") == "_[object HTMLTableElement]_1" ) {
				if (f[0].value){
					f[1].value = option_arp_list[f[0].selectedIndex][2];
					f[2].value = option_arp_list[f[0].selectedIndex][3];
				}
			}

			//check if ip and mac column correct
			if (f[1].value && !f[2].value){
				return v_ip( f[1], quiet );
			}
			if (!f[1].value && f[2].value){
				return v_mac( f[2], quiet );
			}
			if (f[1].value && f[2].value){
				return v_ip( f[1], quiet ) || v_mac( f[2], quiet );
			}
		}
		v2ray_acl.alter_txt = function() {
			if (this.tb.rows.length == "4"){
				$('#footer_ip').html("<i>全部主机 - ip</i>")
				$('#footer_mac').html("<i>全部主机 - mac</i>")
			}else{
				$('#footer_ip').html("<i>其它主机 - ip</i>")
				$('#footer_mac').html("<i>其它主机 - mac</i>")
			}
		}
		v2ray_acl.onAdd = function() {
			var data;
			this.moving = null;
			this.rpHide();
			if (!this.verifyFields(this.newEditor, false)) return;
			data = this.fieldValuesToData(this.newEditor);
			this.insertData(1, data);
			this.disableNewEditor(false);
			this.resetNewEditor();
			this.alter_txt(); // added by sadog
		}
		v2ray_acl.rpDel = function(b) {
			b = PR(b);
			TGO(b).moving = null;
			b.parentNode.removeChild(b);
			this.recolor();
			this.rpHide()
			this.alter_txt(); // added by sadog
		}
		v2ray_acl.resetNewEditor = function() {
			var f;
			f = fields.getAll( this.newEditor );
			ferror.clearAll( f );
			f[ 0 ].value = '';
			f[ 1 ].value   = '';
			f[ 2 ].value   = '';
			f[ 3 ].value   = '1';
		}
		v2ray_acl.footerSet = function(c, b) {
			var f, d;
			elem.remove(this.footer);
			this.footer = f = this._insert(-1, c, b);
			//f.className = "alert alert-info";
			for (d = 0; d < f.cells.length; ++d) {
				f.cells[d].cellN = d;
				f.cells[d].onclick = function() {
					TGO(this).footerClick(this)
				}
			}
			return f
		}
		v2ray_acl.dataToFieldValues = function (data) {
			return [data[0], data[1], data[2], data[3]];
		}
		v2ray_acl.setup = function() {
			this.init( 'v2ray_acl_pannel', '', 254, [
			{ type: 'select',maxlen:20,options:option_arp_list},	//name
			{ type: 'text',maxlen:20},	//name
			{ type: 'text',maxlen:20},	//name
			{ type: 'select',maxlen:20,options:option_acl_mode}	//control
			] );
			this.headerSet( [ '主机别名', '主机IP地址', 'MAC地址', '访问控制'] );
			if (typeof(dbus["v2ray_acl_node_max"]) == "undefined"){
				this.footerSet( [ '<small id="footer_name" style="color:#1bbf35"><i>缺省规则</i></small>','<small id="footer_ip" style="color:#1bbf35"><i>全部主机 - ip</i></small>','<small id="footer_mac" style="color:#1bbf35"><i>全部主机 - mac</small></i>','<select id="_v2ray_acl_default_mode" name="v2ray_acl_default_mode" style="border: 0px solid #222;background: transparent;margin-left:-4px;padding:-0 -0;height:16px;"><option value="0">不代理</option><option value="1">gfwlist黑名单</option><option value="2">大陆白名单</option><option value="3">游戏模式</option><option value="4">全局模式</option></select>']);
			}else{
				this.footerSet( [ '<small id="footer_name" style="color:#1bbf35"><i>缺省规则</i></small>','<small id="footer_ip" style="color:#1bbf35"><i>其它主机 - ip</i></small>','<small id="footer_mac" style="color:#1bbf35"><i>其它主机 - mac</small></i>','<select id="_v2ray_acl_default_mode" name="v2ray_acl_default_mode" style="border: 0px solid #222;background: transparent;margin-left:-4px;padding:-0 -0;height:16px;"><option value="0">不代理</option><option value="1">gfwlist黑名单</option><option value="2">大陆白名单</option><option value="3">游戏模式</option><option value="4">全局模式</option></select>']);
			}
			
			if(typeof(dbus["v2ray_acl_default_mode"]) != "undefined" ){
				E("_v2ray_acl_default_mode").value = dbus["v2ray_acl_default_mode"];
			}else{
				E("_v2ray_acl_default_mode").value = 1;
			}
			
			for ( var i = 1; i <= dbus["v2ray_acl_node_max"]; i++){
				var t = [dbus["v2ray_acl_name_" + i ], 
						dbus["v2ray_acl_ip_" + i ]  || "",
						dbus["v2ray_acl_mac_" + i ]  || "",
						dbus["v2ray_acl_mode_" + i ]]
				if ( t.length == 4 ) this.insertData( -1, t );
			}
			this.recolor();
			this.showNewEditor();
			this.resetNewEditor();
		}
		//============================================
		function init_v2ray(){
			tabSelect('app1');
			verifyFields();
			$("#_v2ray_basic_log").click(
				function() {
					x = 10000000;
			});
			show_hide_panel();
			set_version();
			setTimeout("get_run_status();", 2000);
		}

		function set_version(){
			$('#_v2ray_version').html( '<font color="#1bbf35">V2Ray for LEDE ' + (dbus["v2ray_version"]  || "") + '</font></a>' );
		}

		function get_dbus_data(){
			$.ajax({
			  	type: "GET",
			 	url: "/_api/v2ray",
			  	dataType: "json",
			  	async:false,
			 	success: function(data){
			 	 	dbus = data.result[0];
			  	}
			});
		}
		
		function get_run_status(){
			if (status_time > 99999){
				return false;
			}
			var id1 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id1, "method": "v2ray_status.sh", "params":[2], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if(softcenter == 1){
						return false;
					}
					++status_time;
					if (response.result == '-2'){
						E("_v2ray_basic_status_foreign").innerHTML = "获取运行状态失败！";
						E("_v2ray_basic_status_china").innerHTML = "获取运行状态失败！";
						setTimeout("get_run_status();", 5000);
					}else{
						if(dbus["v2ray_basic_enable"] != "1"){
							E("_v2ray_basic_status_foreign").innerHTML = "国外链接 - 尚未提交，暂停获取状态！";
							E("_v2ray_basic_status_china").innerHTML = "国内链接 - 尚未提交，暂停获取状态！";
						}else{
							E("_v2ray_basic_status_foreign").innerHTML = response.result.split("@@")[0];
							E("_v2ray_basic_status_china").innerHTML = response.result.split("@@")[1];
						}
						setTimeout("get_run_status();", 5000);
					}
				},
				error: function(){
					if(softcenter == 1){
						return false;
					}
					E("_v2ray_basic_status_foreign").innerHTML = "获取运行状态失败！";
					E("_v2ray_basic_status_china").innerHTML = "获取运行状态失败！";
					setTimeout("get_run_status();", 5000);
				}
			});
		}

		function get_arp_list(){
			var id5 = parseInt(Math.random() * 100000000);
			var postData1 = {"id": id5, "method": "v2ray_getarp.sh", "params":[], "fields": ""};
			$.ajax({
				type: "POST",
				url: "/_api/",
				async:true,
				cache:false,
				data: JSON.stringify(postData1),
				dataType: "json",
				success: function(response){
					if (response.result != "-1"){
						var s2 = response.result.split( '>' );
						for ( var i = 0; i < s2.length; ++i ) {
							option_arp_local[i] = [s2[ i ].split( '<' )[0], "【" + s2[ i ].split( '<' )[0] + "】", s2[ i ].split( '<' )[1], s2[ i ].split( '<' )[2]];
						}
						var node_acl = parseInt(dbus["v2ray_acl_node_max"]) || 0;
						for ( var i = 0; i < node_acl; ++i ) {
							option_arp_web[i] = [dbus["v2ray_acl_name_" + (i + 1)], "【" + dbus["v2ray_acl_name_" + (i + 1)] + "】", dbus["v2ray_acl_ip_" + (i + 1)], dbus["v2ray_acl_mac_" + (i + 1)]];
						}			
						option_arp_list = unique_array(option_arp_local.concat( option_arp_web ));
						v2ray_acl.setup();
					}
				},
				error:function(){
					v2ray_acl.setup();
				},
				timeout:1000
			});
		}
		function unique_array(array){
			var r = [];
			for(var i = 0, l = array.length; i < l; i++) {
				for(var j = i + 1; j < l; j++)
				if (array[i][0] === array[j][0]) j = ++i;
					r.push(array[i]);
			}
			return r.sort();;
		}

		function show_hide_panel(){
			var a  = E('_v2ray_basic_enable').checked;
			elem.display('v2ray_status_pannel', a);
			elem.display('v2ray_tabs', a);
			elem.display('v2ray_basic_tab', a);
		}

		function verifyFields(r){
			if (E("_v2ray_dns_plan").value == "1"){
				$('#_v2ray_dns_plan_txt').html("国外dns解析gfwlist名单内的国外域名，剩下的域名用国内dns解析。 ")
			}else if (E("_v2ray_dns_plan").value == "2"){
				$('#_v2ray_dns_plan_txt').html("国内dns解析cdn名单内的国内域名用，剩下的域名用国外dns解析。<font color='#FF3300'>推荐！</font> ")
			}
			// when check/uncheck v2ray_switch
			var a  = E('_v2ray_basic_enable').checked;
			if ( $(r).attr("id") == "_v2ray_basic_enable" ) {
				if(a){
					elem.display('v2ray_status_pannel', a);
					elem.display('v2ray_tabs', a);
					tabSelect('app1')
				}else{
					tabSelect('fuckapp')
				}
			}
			
			var b  = E('_v2ray_dns_china').value == '12';
			elem.display('_v2ray_dns_china_user', b);
			
			var c  = E('_v2ray_dns_foreign').value == '4';
			elem.display('_v2ray_dns_foreign_user', c);
			
			var d = E('_v2ray_basic_mux').checked == '1';
			elem.display(PR('_v2ray_basic_muxnum'), d);

			var f = E('_v2ray_basic_custom').checked == '1';
			elem.display(PR('_v2ray_basic_config'), f);

			return true;
		}
		function tabSelect(obj){
			var tableX = ['app1-tab', 'app2-tab','app3-tab','app4-tab','app5-tab','app6-tab'];
			var boxX = ['boxr1','boxr2','boxr3','boxr4','boxr5','boxr6'];
			var appX = ['app1','app2','app3','app4','app5','app6'];
			for (var i = 0; i < tableX.length; i++){
				if(obj == appX[i]){
					$('#'+tableX[i]).addClass('active');
					$('.'+boxX[i]).show();
				}else{
					$('#'+tableX[i]).removeClass('active');
					$('.'+boxX[i]).hide();
				}
			}
			if(obj=='app6'){
				elem.display('save-button', false);
				elem.display('cancel-button', false);
				noChange=0;
				setTimeout("get_log();", 200);
			}else{
				elem.display('save-button', true);
				elem.display('cancel-button', true);
				noChange=2001;
			}
			if(obj=='fuckapp'){
				elem.display('v2ray_status_pannel', false);
				elem.display('v2ray_tabs', false);
				elem.display('v2ray_basic_tab', false);
				elem.display('v2ray_wblist_tab', false);
				elem.display('v2ray_dns_tab', false);
				elem.display('v2ray_acl_tab', false);
				elem.display('v2ray_log_tab', false);
				E('save-button').style.display = "";
			}
		}
		function showMsg(Outtype, title, msg){
			$('#'+Outtype).html('<h5>'+title+'</h5>'+msg+'<a class="close"><i class="icon-cancel"></i></a>');
			$('#'+Outtype).show();
		}

		function save(){
			setTimeout("tabSelect('app6')", 500);
			status_time = 999999990;
			get_run_status();
			E("_v2ray_basic_status_foreign").innerHTML = "国外链接 - 提交中...暂停获取状态！";
			E("_v2ray_basic_status_china").innerHTML = "国内链接 - 提交中...暂停获取状态！";
			var paras_chk = ["enable", "custom", "mux"];
			var paras_inp = ["v2ray_basic_server", "v2ray_basic_port", "v2ray_basic_password", "v2ray_acl_default_mode", 
							"v2ray_dns_plan", "v2ray_dns_china", "v2ray_dns_china_user", "v2ray_basic_mode", "v2ray_dns_foreign_select", "v2ray_dns_foreign", "v2ray_dns_foreign_user", "v2ray_basic_alterld", "v2ray_basic_auth", "v2ray_basic_muxnum" ];
			// collect data from checkbox
			for (var i = 0; i < paras_chk.length; i++) {
				dbus["v2ray_basic_" + paras_chk[i]] = E('_v2ray_basic_' + paras_chk[i] ).checked ? '1':'0';
			}
			// data from other element
			for (var i = 0; i < paras_inp.length; i++) {
				if (typeof(E('_' + paras_inp[i] ).value) == "undefined"){
					dbus[paras_inp[i]] = "";
				}else{
					dbus[paras_inp[i]] = E('_' + paras_inp[i]).value;
				}
			}
			// data need base64 encode
			var paras_base64 = ["v2ray_wan_white_ip", "v2ray_wan_white_domain", "v2ray_wan_black_ip", "v2ray_wan_black_domain", "v2ray_dnsmasq", "v2ray_basic_config"];
			for (var i = 0; i < paras_base64.length; i++) {
				if (typeof(E('_' + paras_base64[i] ).value) == "undefined"){
					dbus[paras_base64[i]] = "";
				}else{
					dbus[paras_base64[i]] = Base64.encode(E('_' + paras_base64[i]).value);
				}
			}
			// collect acl data from acl pannel
			var v2ray_acl_conf = ["v2ray_acl_name_", "v2ray_acl_ip_", "v2ray_acl_mac_", "v2ray_acl_mode_" ];
			// mark all acl data for delete first
			for ( var i = 1; i <= dbus["v2ray_acl_node_max"]; i++){
				for ( var j = 0; j < v2ray_acl_conf.length; ++j ) {
					dbus[v2ray_acl_conf[j] + i ] = ""
				}
			}
			var data = v2ray_acl.getAllData();
			if(data.length > 0){
				for ( var i = 0; i < data.length; ++i ) {
					for ( var j = 1; j < v2ray_acl_conf.length; ++j ) {
						dbus[v2ray_acl_conf[0] + (i + 1)] = data[i][0];
						dbus[v2ray_acl_conf[j] + (i + 1)] = data[i][j];
					}
				}
				dbus["v2ray_acl_node_max"] = data.length;
			}else{
				dbus["v2ray_acl_node_max"] = "";
			}
			// now post data
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "v2ray_config.sh", "params":[1], "fields": dbus};
			showMsg("msg_warring","正在提交数据！","<b>等待后台运行完毕，请不要刷新本页面！</b>");
			$.ajax({
				url: "/_api/",
				type: "POST",
				async:true,
				cache:false,
				dataType: "json",
				data: JSON.stringify(postData),
				success: function(response){
					if (response.result == id){
						if(E('_v2ray_basic_enable').checked){
							showMsg("msg_success","提交成功","<b>成功提交数据</b>");
							$('#msg_warring').hide();
							setTimeout("$('#msg_success').hide()", 500);
							x = 4;
							count_down_switch();
						}else{
							// when shut down ss finished, close the log tab
							$('#msg_warring').hide();
							showMsg("msg_success","提交成功","<b>v2ray成功关闭！</b>");
							setTimeout("$('#msg_success').hide()", 4000);
							setTimeout("tabSelect('fuckapp')", 4000);
						}
					}else{
						$('#msg_warring').hide();
						showMsg("msg_error","提交失败","<b>提交数据失败！错误代码：" + response.result + "</b>");
						setTimeout("window.location.reload()", 500);
					}
				},
				error: function(){
					showMsg("msg_error","失败","<b>当前系统存在异常查看系统日志！</b>");
					status_time = 1;
				}
			});
		}

		function get_log(){
			$.ajax({
				url: '/_temp/v2ray_log.txt',
				type: 'GET',
				dataType: 'html',
				async: true,
				cache:false,
				success: function(response) {
					var retArea = E("_v2ray_basic_log");
					if (response.search("XU6J03M6") != -1) {
						retArea.value = response.replace("XU6J03M6", " ");
						retArea.scrollTop = retArea.scrollHeight;
						return true;
					}
					if (_responseLen == response.length) {
						noChange++;
					} else {
						noChange = 0;
					}
					if (noChange > 2000) {
						//tabSelect("app1");
						return false;
					} else {
						setTimeout("get_log();", 100); //100 is radical but smooth!
					}
					retArea.value = response;
					retArea.scrollTop = retArea.scrollHeight;
					_responseLen = response.length;
				},
				error: function() {
					E("_v2ray_basic_log").value = "获取日志失败！";
				}
			});
		}
		function count_down_switch() {
			if (x == "0") {
				setTimeout("window.location.reload()", 500);
			}
			if (x < 0) {
				return false;
			}
				--x;
			setTimeout("count_down_switch();", 500);
		}
		function manipulate_conf(script, arg){
			var dbus3 = {};
			if(arg == 2 || arg == 4 || arg == 5){
				tabSelect("app6");
			}
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": script, "params":[arg], "fields": [] };
			$.ajax({
				type: "POST",
				url: "/_api/",
				async: true,
				cache:false,
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response){
					if (script == "v2ray_config.sh"){
						if(arg == 2 || arg == 4 ){
							setTimeout("window.location.reload()", 800);
						}else if (arg == 3){
							var a = document.createElement('A');
							a.href = "/files/v2ray_conf_backup.sh";
							a.download = 'v2ray_conf_backup.sh';
							document.body.appendChild(a);
							a.click();
							document.body.removeChild(a);
						}else if (arg == 5){
							setTimeout("tabSelect('app6')", 500);
							setTimeout("window.location.reload()", 800);
						}
					}
				}
			});
		}
		function restore_conf(){
			var filename = $("#file").val();
			filename = filename.split('\\');
			filename = filename[filename.length-1];
			var filelast = filename.split('.');
			filelast = filelast[filelast.length-1];
			if(filelast !='sh'){
				alert('配置文件格式不正确！');
				return false;
			}
			var formData = new FormData();
			formData.append('v2ray_conf_backup.sh', $('#file')[0].files[0]);
			$('.popover').html('正在恢复，请稍后……');
			//changeButton(true);
			$.ajax({
				url: '/_upload',
				type: 'POST',
				async: true,
				cache:false,
				data: formData,
				processData: false,
				contentType: false,
				complete:function(res){
					if(res.status==200){
						manipulate_conf('v2ray_config.sh', 4);
					}
				}
			});
		}
	</script>
	<div class="box">
		<div class="heading">
			<span id="_v2ray_version"></span>
			<a href="#/soft-center.asp" class="btn" style="float:right;border-radius:3px;margin-right:5px;margin-top:0px;">返回</a>
		</div>
		<div class="content">
			<span class="col" style="line-height:30px;width:700px">
			V2Ray 是一个模块化的代理软件包，它的目标是提供常用的代理软件模块，简化网络代理软件的开发。<br />
			你需要为 V2Ray 安装专用的服务端程序:<a href="https://github.com/v2ray/v2ray-core" target="_blank"> 【点此访问源码项目】 </a><a href="https://www.v2ray.com/chapter_00/install.html" target="_blank"> 【点此访问一键服务器安装脚本】 </a>
		</div>
	</div>
	<div class="box" style="margin-top: 0px;min-width:540px;">
		<div class="heading">
		</div>
		<div class="content">
			<div id="v2ray_switch_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_switch_pannel').forms([
					{ title: '代理开关', name:'v2ray_basic_enable',type:'checkbox',  value: dbus.v2ray_basic_enable == 1 }  // ==1 means default close; !=0 means default open
				]);
			</script>
			<hr />
			<fieldset id="v2ray_status_pannel">
				<label class="col-sm-3 control-left-label" for="_undefined">代理运行状态</label>
				<div class="col-sm-9">
					<font id="_v2ray_basic_status_foreign" name="v2ray_basic_status_foreign" color="#1bbf35">国外链接: waiting...</font>
				</div>
				<div class="col-sm-9" style="margin-top:2px">
					<font id="_v2ray_basic_status_china" name="v2ray_basic_status_china" color="#1bbf35">国内链接: waiting...</font>
				</div>
			</fieldset>
		</div>
	</div>
	<ul id="v2ray_tabs" class="nav nav-tabs" style="min-width:540px;">
		<li><a href="javascript:void(0);" onclick="tabSelect('app1');" id="app1-tab" class="active"><i class="icon-system"></i> 帐号设置</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app4');" id="app4-tab"><i class="icon-lock"></i> 访问控制</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app2');" id="app2-tab"><i class="icon-tools"></i> DNS设定</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app3');" id="app3-tab"><i class="icon-warning"></i> 黑白名单</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app5');" id="app5-tab"><i class="icon-wake"></i> 附加设置</a></li>
		<li><a href="javascript:void(0);" onclick="tabSelect('app6');" id="app6-tab"><i class="icon-hourglass"></i> 查看日志</a></li>	
	</ul>
	<div class="box boxr1" id="v2ray_basic_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="v2ray_basic_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_basic_pannel').forms([
					{ title: '代理模式', name:'v2ray_acl_default_mode',type:'select', options:option_acl_mode, value:dbus.v2ray_acl_default_mode },
					{ title: '服务器类型', name:'v2ray_basic_mode',type:'select', options:option_mode, value:dbus.v2ray_basic_mode },
					{ title: '服务器地址', name:'v2ray_basic_server',type:'text',size: 20,value:dbus.v2ray_basic_server,help: '尽管支持域名格式，但是仍然建议首先使用IP地址。'},
					{ title: '服务器端口', name:'v2ray_basic_port',type:'text',size: 20,value:dbus.v2ray_basic_port },
					{ title: '密码.UUID', name:'v2ray_basic_password',type:'password',size: 50,maxLength:50,value:dbus.v2ray_basic_password,help: '需要和服务器一致。',peekaboo: 1  },
					{ title: 'Alterld', name:'v2ray_basic_alterld',type:'text',size: 20,maxLength:20,value:dbus.v2ray_basic_alterld,help: '需要和服务器一致。'},
					{ title: '加密方式', name:'v2ray_basic_auth',type:'select', options:option_auth, value:dbus.v2ray_basic_auth },
					//{ title: '传输协议', name:'v2ray_basic_transport',type:'select', options:option_transport, value:dbus.v2ray_basic_transport },
					{ title: 'Mux', name:'v2ray_basic_mux',type:'checkbox',  value: dbus.v2ray_basic_mux == 1,help: '开启多路复用' },
					{ title: 'Mux并发连接数', name:'v2ray_basic_muxnum',type:'text',size: 5,value:dbus.v2ray_basic_muxnum || '8'},
					{ title: '自定义配置文件', name:'v2ray_basic_custom',type:'checkbox',  value: dbus.v2ray_basic_custom == 1 ,help: '本选项勾选后以上配置无效，主流量本地监听端口必须为1280'},
					{ title: '<b>配置文件内容</b></br></br><font color="#B2B2B2">本地监听端口必须为<b>1280</b></font>', name:'v2ray_basic_config',type:'textarea', value: Base64.decode(dbus.v2ray_basic_config)||"", style: 'width: 100%; height:450px;' },
				]);
			</script>
		</div>
	</div>
	<div class="box boxr2" id="v2ray_dns_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="v2ray_dns_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_dns_pannel').forms([
					{ title: 'DNS解析偏好', name:'v2ray_dns_plan',type:'select',options:[['1', '国内优先'], ['2', '国外优先']], value: dbus.v2ray_dns_plan || "2", suffix: '<lable id="_v2ray_dns_plan_txt"></lable>'},
					{ title: '选择国内DNS', multi: [
						{ name: 'v2ray_dns_china',type:'select', options:option_dns_china, value: dbus.v2ray_dns_china || "1", suffix: ' &nbsp;&nbsp;' },
						{ name: 'v2ray_dns_china_user', type: 'text', value: dbus.v2ray_dns_china_user }
					]},
					// dns foreign pcap
					{ title: '选择国外DNS', multi: [
						{ name: 'v2ray_dns_foreign_select',type: 'select', options:option_dns_foreign, value: dbus.v2ray_dns_dns_foreign || "1", suffix: ' &nbsp;&nbsp;' },
						{ name: 'v2ray_dns_foreign',type: 'select', options:option_v2ray_dns_foreign, value: dbus.v2ray_dns_foreign || "2", suffix: ' &nbsp;&nbsp;' },
						{ name: 'v2ray_dns_foreign_user', type: 'text', value: dbus.v2ray_dns_foreign_user || "8.8.8.8:53" },
						{ suffix: '<lable>默认使用 v2ray 内置的DNS功能解析国外域名。</lable>' }
					]},
					{ title: '<b>自定义dnsmasq</b></br></br><font color="#B2B2B2">一行一个，错误的格式会导致dnsmasq不能启动，格式：</br>address=/koolshare.cn/2.2.2.2</br>bogus-nxdomain=220.250.64.18</br>conf-file=/koolshare/mydnsmasq.conf</font>', name: 'v2ray_dnsmasq', type: 'textarea', value: Base64.decode(dbus.v2ray_dnsmasq)||"", style: 'width: 100%; height:150px;' }
				]);
			</script>
		</div>
	</div>
	<div class="box boxr3" id="v2ray_wblist_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="v2ray_wblist_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_wblist_pannel').forms([
					{ title: '<b>IP/CIDR白名单</b></br></br><font color="#B2B2B2">不需要加速的外网ip/cidr地址，一行一个，例如：</br>2.2.2.2</br>3.3.0.0/16</font>', name: 'v2ray_wan_white_ip', type: 'textarea', value: Base64.decode(dbus.v2ray_wan_white_ip)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>域名白名单</b></br></br><font color="#B2B2B2">不需要加速的域名，例如：</br>google.com</br>facebook.com</font>', name: 'v2ray_wan_white_domain', type: 'textarea', value: Base64.decode(dbus.v2ray_wan_white_domain)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>IP/CIDR黑名单</b></br></br><font color="#B2B2B2">需要加速的外网ip/cidr地址，一行一个，例如：</br>4.4.4.4</br>5.0.0.0/8</font>', name: 'v2ray_wan_black_ip', type: 'textarea', value: Base64.decode(dbus.v2ray_wan_black_ip)||"", style: 'width: 100%; height:150px;' },
					{ title: '<b>域名黑名单</b></br></br><font color="#B2B2B2">需要加速的域名,例如：</br>baidu.com</br>koolshare.cn</font>', name: 'v2ray_wan_black_domain', type: 'textarea', value: Base64.decode(dbus.v2ray_wan_black_domain)||"", style: 'width: 100%; height:150px;' }
				]);
			</script>
		</div>
	</div>	
	<div class="box boxr4" id="v2ray_acl_tab" style="margin-top: 0px;">
		<div class="content">
			<div class="tabContent">
				<table class="line-table" cellspacing=1 id="v2ray_acl_pannel"></table>
			</div>
			<br><hr>
		</div>
	</div>
	<div class="box boxr5" id="v2ray_addon_tab" style="margin-top: 0px;">
		<div class="heading"></div>
		<div class="content" style="margin-top: -20px;">
			<div id="v2ray_addon_pannel" class="section"></div>
			<script type="text/javascript">
				$('#v2ray_addon_pannel').forms([
					{ title: 'V2Ray 数据操作', suffix: '<button onclick="manipulate_conf(\'v2ray_config.sh\', 2);" class="btn btn-success">清除所有 v2ray 数据</button>&nbsp;&nbsp;&nbsp;&nbsp;<button onclick="manipulate_conf(\'v2ray_config.sh\', 3);" class="btn btn-download">备份所有 v2ray 数据</button>' },
					{ title: 'V2Ray 数据恢复', suffix: '<input type="file" id="file" size="50">&nbsp;&nbsp;<button id="upload1" type="button"  onclick="restore_conf();" class="btn btn-danger">上传并恢复 <i class="icon-cloud"></i></button>' },
					{ title: 'V2Ray 当前版本', suffix: '<a id="v2ray_version" href="https://github.com/txthinking/v2ray/releases" target="_blank"></a>'},
					{ title: 'V2Ray 版本升级', suffix: '<button onclick="manipulate_conf(\'v2ray_config.sh\', 5);" class="btn btn-download">一键升级v2ray 版本</button>' }
				]);
				$('#v2ray_version').html(dbus.v2ray_basic_version || "未初始化");
			</script>
		</div>
	</div>
	<div class="box boxr6" id="v2ray_log_tab" style="margin-top: 0px;">
		<div id="v2ray_log_pannel" class="content">
			<div class="section content">
				<script type="text/javascript">
					y = Math.floor(docu.getViewSize().height * 0.45);
					s = 'height:' + ((y > 300) ? y : 300) + 'px;display:block';
					$('#v2ray_log_pannel').append('<textarea class="as-script" name="_v2ray_basic_log" id="_v2ray_basic_log" readonly wrap="off" style="max-width:100%; min-width: 100%; margin: 0; ' + s + '" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>');
				</script>
			</div>
		</div>
	</div>
	<div id="msg_warring" class="alert alert-warning icon" style="display:none;"></div>
	<div id="msg_success" class="alert alert-success icon" style="display:none;"></div>
	<div id="msg_error" class="alert alert-error icon" style="display:none;"></div>
	<button type="button" value="Save" id="save-button" onclick="save()" class="btn btn-primary">提交 <i class="icon-check"></i></button>
	<button type="button" value="Cancel" id="cancel-button" onclick="javascript:reloadPage();" class="btn">取消 <i class="icon-cancel"></i></button>
	<script type="text/javascript">init_v2ray();</script>
</content>
