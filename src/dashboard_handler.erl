-module(dashboard_handler).
-export([init/3, handle/2, terminate/2]).

init({tcp, http}, Req, _Opts) ->
    {ok, Req, {}}.

handle(Req, State) ->
    {ok, Req2} = cowboy_http_req:reply(200, [], page(), Req),
    {ok, Req2, State}.

terminate(_Req, _State) ->
    ok.

page() ->
	<<"<html>\n<head>\n<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js\" type=\"text/javascript\"></script>\n<script src=\"http://www.highcharts.com/js/highstock.js\" type=\"text/javascript\"></script>\n<script type=\"text/javascript\">\n\n// utility functions\nfunction getUrlVars()\n{\n    var vars = [], hash;\n    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');\n    for(var i = 0; i < hashes.length; i++)\n    {\n        hash = hashes[i].split('=');\n        vars.push(hash[0]);\n        vars[hash[0]] = hash[1];\n    }\n    return vars;\n}\n\nfunction timeToPointStart(Time){\n\treturn Date.UTC(Time.getUTCFullYear(), Time.getUTCMonth(), Time.getUTCDate(), Time.getUTCHours(), Time.getUTCMinutes(), Time.getUTCSeconds())\n};\n\nfunction compareI(a, b) {\n  if (a.i < b.i)\n     return -1;\n  if (a.i > b.i)\n    return 1;\n  return 0;\n}\n\n// global variables\nvar Origin = window.location.origin;\n// var Origin = \"http://localhost:8080\";\n\nvar Now = $.now();\nvar Second = 1000;\nvar Minute = Second * 60;\nvar Hour = Minute * 60;\nvar Day = Hour * 24;\nvar Month = Day * 30;\nvar Year = Month * 12;\n\nvar Plot;\nvar SecondPlot;\nvar MinutePlot;\nvar HourPlot;\n\n\nTags = [\n\tgetUrlVars()[\"tag1\"],\n\tgetUrlVars()[\"tag2\"],\n\tgetUrlVars()[\"tag3\"],\n\tgetUrlVars()[\"tag4\"],\n\tgetUrlVars()[\"tag5\"],\n];\nTags = jQuery.grep(Tags, function(tag, i) {return (tag != null)});\n\nSecondsURLFun = function(Origin, Tag, StartTime, ItemCount) {\n\treturn Origin + '/annalist/second_counts/' + Tag + '/' +\n\t\t\t\t\tStartTime.getUTCFullYear() + '/' +\n\t\t\t\t\t(StartTime.getUTCMonth() + 1) + '/' +\n\t\t\t\t\tStartTime.getUTCDate() + '/' +\n\t\t\t\t\tStartTime.getUTCHours() + '/' +\n\t\t\t\t\tStartTime.getUTCMinutes() + '/' +\n\t\t\t\t\t(StartTime.getUTCSeconds() + 1) + '/' +\n\t\t\t\t\tItemCount\n}\n\nMinutesURLFun = function(Origin, Tag, StartTime, ItemCount) {\n\treturn Origin + '/annalist/minute_counts/' + Tag + '/' +\n\t\t\t\t\tStartTime.getUTCFullYear() + '/' +\n\t\t\t\t\t(StartTime.getUTCMonth() + 1) + '/' +\n\t\t\t\t\tStartTime.getUTCDate() + '/' +\n\t\t\t\t\tStartTime.getUTCHours() + '/' +\n\t\t\t\t\tStartTime.getUTCMinutes() + '/' +\n\t\t\t\t\tItemCount\n}\n\nHoursURLFun = function(Origin, Tag, StartTime, ItemCount) {\n\treturn Origin + '/annalist/hour_counts/' + Tag + '/' +\n\t\t\t\t\tStartTime.getUTCFullYear() + '/' +\n\t\t\t\t\t(StartTime.getUTCMonth() + 1) + '/' +\n\t\t\t\t\tStartTime.getUTCDate() + '/' +\n\t\t\t\t\tStartTime.getUTCHours() + '/' +\n\t\t\t\t\tItemCount\n}\n\nPlot = function(ChartId, Title, Origin, URLFun, StartTime, ItemCount, Interval, Buttons) {\n\tURLsAndTags = jQuery.map(\n\t\tTags,\n\t\tfunction(Tag, i){\n\t\t\treturn ({\n\t\t\t\turl : URLFun(Origin, Tag, StartTime, ItemCount),\n\t\t\t\ttag : Tag,\n\t\t\t\ti : i\n\t\t\t});\n\t});\n\tvar Requests = [];\n\tvar Datas = [];\n\tvar DataTags = [];\n\tvar Series = [];\n\t// collect the data from the API\n\t$.each(URLsAndTags, function (i, UrlAndTag) {\n\t\tRequests.push(\n\t        $.getJSON(UrlAndTag.url + '?callback=?', function (json) {\n\t        \tSeries.push({\n\t\t\t\t\t\tanimation: false,\n\t\t\t\t\t\tpointStart: timeToPointStart(StartTime),\n\t\t\t\t\t\tpointInterval: Interval,\n\t\t\t\t\t\tdata : json,\n\t\t\t\t\t\tname: UrlAndTag.tag.replace('%20', '/'),\n\t\t\t\t\t\ti: UrlAndTag.i,\n\t\t\t\t\t\ttooltip: {yDecimals: 0}\n\t\t\t\t\t})\n\t        })\n\t    );\n\t});\n\t// we wait for the JSONP requests to return\n\t$.when.apply(this, Requests).done(\n\t\tfunction(){\n\t\t\t// chart creation\n\t\t\tHighcharts.StockChart({\n\t\t\t\trangeSelector : {buttons : Buttons},\n\t\t\t\tyAxis : {min : 0},\n\t\t\t\tchart : {renderTo : 'chart' + ChartId},\n\t\t\t\tplotOptions : {line : {dataGrouping : {approximation : \"high\"}}},\n\t\t\t\ttitle : {text : Title},\n\t\t\t\tlegend: {enabled: true},\t\t\t\n\t\t\t\tseries: Series.sort(compareI)\n\t\t\t});\n\t\t}\n\t)\n};\n\n\n\nOneHourAgo = new Date($.now() - Hour);\nPlot(1, \"Last Hour (Seconds)\", Origin, SecondsURLFun, OneHourAgo, Hour / Second, Second,\n\t[\n\t\t{\n\t\t\ttype: 'minute',\n\t\t\tcount: 1,\n\t\t\ttext: '1m'\n\t\t},{\n\t\t\ttype: 'minute',\n\t\t\tcount: 15,\n\t\t\ttext: '15m'\n\t\t}, {\n\t\t\ttype: 'all',\n\t\t\ttext: 'All'\n\t\t\t\t\t\t}]\n);\n\nOneDayAgo = new Date($.now() - Day);\nPlot(2, \"Last Day (Seconds)\", Origin, SecondsURLFun, OneDayAgo, Day / Second, Second,\n\t[\n\t\t{\n\t\t\ttype: 'minute',\n\t\t\tcount: 15,\n\t\t\ttext: '15m'\n\t\t}, {\n\t\t\ttype: 'hour',\n\t\t\tcount: 1,\n\t\t\ttext: '1h'\n\t\t}, {\n\t\t\ttype: 'hour',\n\t\t\tcount: 6,\n\t\t\ttext: '6h'\n\t\t}, {\n\t\t\ttype: 'all',\n\t\t\ttext: 'All'\n\t\t\t\t\t\t}]\n);\n\nOneMonthAgo = new Date($.now() - Month);\nPlot(3, \"Last Month (Minutes)\", Origin, MinutesURLFun, OneMonthAgo, Month / Minute, Minute,\n\t[\n\t\t{\n\t\t\ttype: 'day',\n\t\t\tcount: 1,\n\t\t\ttext: '1d'\n\t\t}, {\n\t\t\ttype: 'day',\n\t\t\tcount: 7,\n\t\t\ttext: '1w'\n\t\t}, {\n\t\t\ttype: 'all',\n\t\t\ttext: 'All'\n\t\t\t\t\t\t}]\n);\n\nOneYearAgo = new Date($.now() - Year);\nPlot(4, \"Last Year (Hours)\", Origin, HoursURLFun, OneYearAgo, Year / Hour, Hour,\n\t[\n\t\t{\n\t\t\ttype: 'month',\n\t\t\tcount: 1,\n\t\t\ttext: '1m'\n\t\t}, {\n\t\t\ttype: 'month',\n\t\t\tcount: 3,\n\t\t\ttext: '3m'\n\t\t}, {\n\t\t\ttype: 'all',\n\t\t\ttext: 'All'\n\t\t\t\t\t\t}]\n);\n\n</script>\n\n\n</script>\n</head>\n<body>\n<div id=\"chart1\" style=\"width: 800px; margin-left: 10px; float: left; height: 400px\"></div>\n<div id=\"chart2\" style=\"width: 800px; margin-left: 10px; float: left; height: 400px\"></div>\n<div id=\"chart3\" style=\"width: 800px; margin-left: 10px; float: left; height: 400px\"></div>\n<div id=\"chart4\" style=\"width: 800px; margin-left: 10px; float: left; height: 400px\"></div>\n</html>\n">>.