# BugTrackerNet
my fork BugTracker.NET with russian specific
Culture ru_RU, all words is translate to russian language
# Requires
1. ASP.NET 2.0 or high
2. MSSQL2005 or high
3. ISS 5.1 or high
# Install
1. create data base with name "btnet"
2. Execute script "setup.sql"
3. change (local), (user), (X) fields in ConnectionString in Web.config
`<add key="ConnectionString" value="server=(local);database=btnet;user id=(user);password=(X);Trusted_Connection=no;"/>`
