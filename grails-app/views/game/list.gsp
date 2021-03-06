<%--
  Created by IntelliJ IDEA.
  User: Gerardo
  Date: 10/04/13
  Time: 21:05
  To change this template use File | Settings | File Templates.
--%>

<%@ page import="cern.ais.gridwars.Outcome; cern.ais.gridwars.MatchPlayer" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>GridWars - Game list</title>
    <style type="text/css">
    td {
        text-align: center;
        padding: 10px;
    }
    </style>
</head>

<body>
<div>${session.user.username} | <g:link controller="user" action="logout">Logout</g:link> |
<g:link controller="game" action="index">View active bot scoreboard</g:link> |
<g:link controller="game" action="list">List games</g:link> |
<g:link controller="agentUpload" action="index">Upload a new bot</g:link> |
    <a href="/api/doc">API Documentation</a> |
    <a href="/api/api.jar">API Download</a> |
    <a href="/api/examples">Examples</a>
</div>
<table>
    <tr><th>Start date</th><th>Players</th><th>Winner</th></tr>
    <g:each in="${games}" var="game">
        <tr>
            <td>
                ${game.startDate.format("yyyy-MM-dd HH:mm:ss")}
            </td>
            <td>
                ${game.players.agent.team.flatten().sort { it.id }.username.join(' vs ')}
            </td>
            <td>
                ${game.players.every { it.outcome.equals(Outcome.DRAW) } ? "Draw" : game.players.find { it.outcome.equals(Outcome.WIN) }.agent.team.username}
            </td>
            <td>
                <g:link controller="game" action="view" params="[id: game.id]">View</g:link>
            </td>
        </tr>
    </g:each>
</table>
</body>
</html>