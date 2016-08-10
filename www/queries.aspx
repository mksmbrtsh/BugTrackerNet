<%@ Page language="C#"%>
<!--
Copyright 2002-2011 Corey Trager
Distributed under the terms of the GNU General Public License
-->
<!-- #include file = "inc.aspx" -->

<script language="C#" runat="server">

DataSet ds;

Security security;

void Page_Load(Object sender, EventArgs e)
{

	Util.do_not_cache(Response);
	
	security = new Security();

	security.check_security( HttpContext.Current, Security.ANY_USER_OK_EXCEPT_GUEST);

	titl.InnerText = Util.get_setting("AppTitle","BugTracker.NET") + " - "
		+ "�������";

	string sql = "";

	if (security.user.is_admin || security.user.can_edit_sql)
	{
		// allow admin to edit all queries

		sql =  @"select
			qu_desc [������],
			case
				when isnull(qu_user,0) = 0 and isnull(qu_org,0) is null then 'everybody'
				when isnull(qu_user,0) <> 0 then 'user:' + us_username
				when isnull(qu_org,0) <> 0 then 'org:' + og_name
				else ' '
				end [���������],
			'<a href=bugs.aspx?qu_id=' + convert(varchar,qu_id) + '>���������� ������</a>' [���������� ������],
			'<a target=_blank href=print_bugs.aspx?qu_id=' + convert(varchar,qu_id) + '>������ ������</a>' [������ ������],
			'<a target=_blank href=print_bugs.aspx?format=excel&qu_id=' + convert(varchar,qu_id) + '>������� � excel</a>' [������� � excel],
			'<a target=_blank href=print_bugs2.aspx?qu_id=' + convert(varchar,qu_id) + '>������ �����������</a>' [������ ������<br> � ������������],
			'<a href=edit_query.aspx?id=' + convert(varchar,qu_id) + '>�������������</a>' [�������������],
			'<a href=delete_query.aspx?id=' + convert(varchar,qu_id) + '>�������</a>' [�������],
			replace(convert(nvarchar(4000),qu_sql), char(10),'<br>') [sql]
			from queries
			left outer join users on qu_user = us_id
			left outer join orgs on qu_org = og_id
			where 1 = $all /* all */
			or isnull(qu_user,0) = $us
			or isnull(qu_user,0) = 0
			order by qu_desc";

		sql = sql.Replace("$all", show_all.Checked ? "1" : "0");
	}
	else
	{
		// allow editing for users' own queries

		sql =  @"select
			qu_desc [������],
			'<a href=bugs.aspx?qu_id=' + convert(varchar,qu_id) + '>view list</a>' [�������� ������],
			'<a target=_blank href=print_bugs.aspx?qu_id=' + convert(varchar,qu_id) + '>print list</a>' [������ ������],
			'<a target=_blank href=print_bugs.aspx?format=excel&qu_id=' + convert(varchar,qu_id) + '>export as excel</a>' [������� � excel],
			'<a target=_blank href=print_bugs2.aspx?qu_id=' + convert(varchar,qu_id) + '>print detail</a>' [������ ������<br>� ������������],
			'<a href=edit_query.aspx?id=' + convert(varchar,qu_id) + '>rename</a>' [�������������],
			'<a href=delete_query.aspx?id=' + convert(varchar,qu_id) + '>delete</a>' [�������]
			from queries
			inner join users on qu_user = us_id
			where isnull(qu_user,0) = $us
			order by qu_desc";
	}

	sql = sql.Replace("$us",Convert.ToString(security.user.usid));
	ds = btnet.DbUtil.get_dataset(sql);

}

</script>

<html>
<head>
<title id="titl" runat="server">btnet �������</title>
<link rel="StyleSheet" href="btnet.css" type="text/css">
<script type="text/javascript" language="JavaScript" src="sortable.js"></script>
</head>

<body>
<% security.write_menu(Response, "queries"); %>

<div class=align>

<% if (security.user.is_admin || security.user.can_edit_sql) { %>
	<table border=0 width=80%><tr>
		<td align=left valign=top>
			<a href=edit_query.aspx>�������� ����� ������</a>
		<td align=right valign=top>
			<form runat="server">
				<span class=lbl>���������� ������ ������� �����:</span>
				<asp:CheckBox id="show_all" class="cb" runat="server" AutoPostback="True" />
			</form>
	</table>
<%

}
else
{
	Response.Write ("<p>");
}

%>


<%

if (ds.Tables[0].Rows.Count > 0)
{
	SortableHtmlTable.create_from_dataset(
		Response, ds, "", "", false);
}
else
{
	Response.Write ("��� �������� � ���� ������.");
}

%>
</div>
<% Response.Write(Application["custom_footer"]); %></body>
</html>