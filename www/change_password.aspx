<%@ Page language="C#" validateRequest="false"%>
<!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
<!-- #include file = "inc.aspx" -->

<script language="C#" runat="server">




///////////////////////////////////////////////////////////////////////
void Page_Load(Object sender, EventArgs e)
{

	Util.set_context(HttpContext.Current);
	Util.do_not_cache(Response);

	if (!IsPostBack)
	{
		titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
			+ "change password";
	}
	else
	{
		msg.InnerHtml = "";

		if (string.IsNullOrEmpty(password.Value))
		{
			msg.InnerHtml = "Введите ваш пароль.";
		}
		else if (password.Value != confirm.Value)
		{
			msg.InnerHtml = "Введенный пароль не совпадает";
		}
		else if (!Util.check_password_strength(password.Value))
		{
			msg.InnerHtml = "Password is not difficult enough to guess.";
			msg.InnerHtml += "<br>Avoid common words.";
			msg.InnerHtml += "<br>Try using a mixture of lowercase, uppercase, digits, and special characters.";
		}
		else
		{
			

			string guid = Request["id"];

			if (string.IsNullOrEmpty(guid))
			{
				Response.Write("no guid");
				Response.End();
			}

			string sql = @"
declare @expiration datetime
set @expiration = dateadd(n,-$minutes,getdate())

select *,
	case when el_date < @expiration then 1 else 0 end [expired]
	from emailed_links
	where el_id = '$guid'

delete from emailed_links
	where el_date < dateadd(n,-240,getdate())";

			sql = sql.Replace("$minutes",Util.get_setting("RegistrationExpiration","20"));
			sql = sql.Replace("$guid",guid.Replace("'","''"));

			DataRow dr = btnet.DbUtil.get_datarow(sql);

			if (dr == null)
			{
				msg.InnerHtml = "The link you clicked on is expired or invalid.<br>Please start over again.";
			}
			else if ((int) dr["expired"] == 1)
			{
				msg.InnerHtml = "The link you clicked has expired.<br>Please start over again.";
			}
			else
			{
				Util.update_user_password((int) dr["el_user_id"], password.Value);
				msg.InnerHtml = "Your password has been changed.";
			}

		}
	}
}


</script>

<html>
<head>
<title id="titl" runat="server">Смена пароля</title>
<link rel="StyleSheet" href="btnet.css" type="text/css">
</head>
<body onload="document.forms[0].password.focus()">
<table border=0><tr>

<%

Response.Write (Application["custom_logo"]);

%>

</table>


<div align="center">
<table border=0><tr><td>
<form class=frm runat="server">
	<table border=0>

	<tr>
	<td class=lbl>Введите новый пароль:</td>
	<td><input runat="server" type=password class=txt id="password" size=20 maxlength=20 autocomplete=off ></td>
	</tr>

	<tr>
	<td class=lbl>Повторите новый пароль:</td>
	<td><input runat="server" type=password class=txt id="confirm" size=20 maxlength=20 autocomplete=off ></td>
	</tr>

	<tr><td colspan=2 align=left>
	<span runat="server" class=err id="msg">&nbsp;</span>
	</td></tr>

	<tr><td colspan=2 align=center>
	<input class=btn type=submit value="Сменить пароль" runat="server">
	</td></tr>

	</table>
</form>

<a href="default.aspx">Вернуться на главную</a>

</td></tr></table>

</div>
</body>
</html>