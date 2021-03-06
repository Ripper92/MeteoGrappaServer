<%-- 
    Document   : index
    Created on : 25-apr-2015, 15.10.33
    Author     : Alessandro
--%>

<%@page import="java.util.Calendar"%>
<%@page import="java.sql.Timestamp"%>
<%@page import="java.util.Date"%>
<%@page import="webside.DBReader"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Grafici</title>
        <link href="css/blogPostStyle.css" rel="stylesheet" type="text/css">
        <!--The following script tag downloads a font from the Adobe Edge Web Fonts server for use within the web page. We recommend that you do not modify it.-->
        <script>var __adobewebfontsappname__ = "dreamweaver"</script>
        <script src="http://use.edgefonts.net/montserrat:n4:default;source-sans-pro:n2:default.js" type="text/javascript"></script>
        <link type="text/css" rel="stylesheet" href="graph/graph.css">
        <link type="text/css" rel="stylesheet" href="graph/detail.css">
        <link type="text/css" rel="stylesheet" href="graph/lines.css">

        <script src="graph/d3.v3.js"></script>
        <script src="graph/rickshaw.js"></script>
        <script type="text/javascript">
            function createGraph(data, axis, chart, colours, names) {
                var graph, max, min, point, scales, series, scales;
                width = $("#bannerImage").width() - 50;
                height = width / 2;
                min = Number.MAX_VALUE;
                max = Number.MIN_VALUE;
                for (var i = 0; i < data.length; i++) {
                    series = data[i];
                    for (var j = 0; j < series.length; j++) {
                        point = series[j];
                        min = Math.min(min, point.y);
                        max = Math.max(max, point.y);
                    }
                }
                scales = d3.scale.linear().domain([min, max]).nice();
                series = [];
                for (var i = 0; i < data.length; i++) {
                    series.push({color: colours[i], data: data[i], name: names[i], scale: scales});
                }

                graph = new Rickshaw.Graph({
                    element: document.getElementById(chart),
                    renderer: 'line',
                    width: width,
                    height: height,
                    strokeWidth: 1.5,
                    series: series
                });
                new Rickshaw.Graph.Axis.Y.Scaled({
                    element: document.getElementById(axis),
                    graph: graph,
                    orientation: 'left',
                    height: height,
                    scale: scales,
                    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
                });
                new Rickshaw.Graph.Axis.Time({
                    graph: graph,
                    height: height
                });
                new Rickshaw.Graph.HoverDetail({
                    graph: graph
                });

                graph.render();
            }
        </script>


        <style type="text/css">
            .axis0 {
                position: absolute;
                width: 40px;
            }
            #axis1 {
                position: absolute;
                left: 1050px;
                width: 40px;
            }
            .chart {
                position: relative;
                left: 50px;
            }
        </style>
    </head>

    <body>
        <div id="mainwrapper">
            <header>
                <!--**************************************************************************
                  Header starts here. It contains Logo and 3 navigation links.
                  ****************************************************************************-->
                <div id="logo" class="links"><!-- Company Logo text --><a href=index.jsp>Meteo del monte Grappa</a></div>
                <nav> <a href="grafici.jsp" title="Link">Grafici</a>  </nav>
            </header>
            <div id="content">
                <section id="mainContent">

                    <!--************************************************************************
                      Main Blog content starts here
                      ****************************************************************************-->
                    <h1><!-- Blog title -->Storico dei dati in grafici</h1>
                    <div id="bannerImage"><img src="img/Montegrappa.jpg" alt=""/></div>
                    <script type="text/javascript" src="http://code.jquery.com/jquery-2.1.3.min.js"></script>
                    <p>
                    <table style="width:100%; text-align: center;" class="links">
                        <tr>
                            <td width="20%"><a href="?type=24">Ultime 24 ore</a></td>
                            <td width="20%"><a href="?type=7">Ultima settimana</a></td>
                            <td width="20%"><a href="?type=15">Mese corrente</a></td>
                            <td width="20%"><a href="?type=30">Ultimo mese</a></td>
                            <td width="20%"><a href="?">Totali</a></td>
                        </tr>
                    </table>
                    </p>
                    <p>
                        Temperature [�C]: <br />
                    </p>
                    <div id="temperature" class="graph">
                        <div id="tempAxis0" class="axis0"></div>
                        <div id="tempChart" class="chart"></div>
                    </div>
                    <p>
                        Umidit� [%]: <br />
                    </p>
                    <div id="humidity" class="graph">
                        <div id="humAxis0" class="axis0"></div>
                        <div id="humChart" class="chart"></div>
                    </div>
                    <p>
                        Velocit� del vento [km/h]: <br />
                    </p>
                    <div id="wind" class="graph">
                        <div id="windAxis0" class="axis0"></div>
                        <div id="windChart" class="chart"></div>
                    </div>
                    <p>
                        Intensit� pioggia [mm/h]: <br />
                    </p>
                    <div id="rain" class="graph">
                        <div id="rainAxis0" class="axis0"></div>
                        <div id="rainChart" class="chart"></div>
                    </div>
                    <%
                        String clause = "";
                        try {
                            int type = Integer.parseInt(request.getParameter("type"));
                            Calendar cal = Calendar.getInstance();
                            String time;
                            switch (type) {
                                case 24:
                                    // last 24 hours
                                    cal.set(Calendar.DAY_OF_YEAR, cal.get(Calendar.DAY_OF_YEAR) - 1);
                                    time = new Timestamp(cal.getTimeInMillis()).toString();
                                    clause = "datetime > '" + time + "'";
                                    break;
                                case 7:
                                    // last week
                                    cal.set(Calendar.WEEK_OF_YEAR, cal.get(Calendar.WEEK_OF_YEAR) - 1);
                                    time = new Timestamp(cal.getTimeInMillis()).toString();
                                    clause = "datetime > '" + time + "'";
                                    break;
                                case 15:
                                    // current month
                                    cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), 1, 0, 0, 0);
                                    time = new Timestamp(cal.getTimeInMillis()).toString();
                                    clause = "datetime > '" + time + "'";
                                    break;
                                case 30:
                                    // last month
                                    cal.set(Calendar.MONTH, cal.get(Calendar.MONTH) - 1);
                                    time = new Timestamp(cal.getTimeInMillis()).toString();
                                    clause = "datetime > '" + time + "'";
                                    break;
                            }
                        } catch (NumberFormatException ex) {
                            // do nothing: type not set
                        }
                        String temperature = DBReader.readDataGraph("temperature", "temperature, feel_temperature, deaf_temperature", clause, "datetime");
                        String humidity = DBReader.readDataGraph("humidity", "humidity", clause, "datetime");
                        String wind = DBReader.readDataGraph("wind", "wind_speed", clause, "datetime");
                        String rain = DBReader.readDataGraph("rain", "rain", clause, "datetime");
                        out.println("<script type=\"text/javascript\">" + temperature + "\n" + humidity + "\n" + wind + "\n" + rain + "\n</script>");
                    %>
                    <script type="text/javascript">
            window.onload = window.onresize = function () {
                $(".axis0").html("");
                $(".chart").html("");
                createGraph(temperature, "tempAxis0", "tempChart", ["red", "blue", "grey"], ["Temperatura", "Temperatura percepita", "Punto di rugiada"]);
                createGraph(humidity, "humAxis0", "humChart", ["red"], ["Umidit�"]);
                createGraph(wind, "windAxis0", "windChart", ["green"], ["Velocit�"]);
                createGraph(rain, "rainAxis0", "rainChart", ["blue"], ["Pioggia"]);
            }
                    </script>

                </section>
                <div id="sidebar">
                    <!--************************************************************************
                    Sidebar starts here. It contains a searchbox, sample ad image and 6 links
                    ****************************************************************************-->
                    Webcam
                    <nav>
                        <ul>
                            <li><a href="http://www.skylinewebcams.com/webcam/italia/veneto/treviso/cima-grappa.html?w=210" title="Link">Sacrario</a></li>
                            <li><a href="http://www.cimagrappa.it/meteo/webcam2.php" title="Link">Sud-est</a></li>
                            <li><a href="http://www.cimagrappa.it/meteo/webcam4.php" title="Link">Est</a></li>
                            <li><a href="http://www.cimagrappa.it/meteo/webcam3.php" title="Link">Nord</a></li>
                        </ul>
                    </nav>
                </div>

                <footer>
                    <!--************************************************************************
                    Footer starts here
                    ****************************************************************************-->
                    <article>
                        <p><center>I dati sono estratti dal sito <a href="http://www.cimagrappa.it/meteo/">cimagrappa.it</a></center></p>
                    </article>
                </footer>
            </div>
            <div id="footerbar"><!-- Small footerbar at the bottom --></div>
        </div>
    </body>
</html>
