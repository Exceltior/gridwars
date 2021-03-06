<%--
  Created by IntelliJ IDEA.
  User: Gerardo
  Date: 13/04/13
  Time: 16:34
  To change this template use File | Settings | File Templates.
--%>

<%@ page import="cern.ais.gridwars.Outcome; cern.ais.gridwars.GameConstants; cern.ais.gridwars.MatchPlayer" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>GridWars - Game Viewer</title>
    <script>

        var frameArray = [];
        var loc = window.location, ws_uri;
        if (loc.protocol === "https:")
        {
            ws_uri = "wss:";
        }
        else
        {
            ws_uri = "ws:";
        }
        ws_uri += "//" + loc.host;
        ws_uri += "/game.ws";

        var ws = new WebSocket(ws_uri);
        ws.binaryType = "arraybuffer";

        var universeSize = 50;
        var currentTurn = 0;
        var currentRenderedFrame = 0;

        var isPlaying = 0;
        var playInterval;
        var delay = 50;

        drawFrame = function (frameNumber)
        {
            // Canvas
            var canvasHeight = document.getElementById("gameCanvas").height;
            var canvasWidth = document.getElementById("gameCanvas").width;
            var c = document.getElementById("preCanvas");
            var ctx = c.getContext("2d");
            var extractedData = new Uint8Array(frameArray[frameNumber].data);
            var imageData = ctx.createImageData(universeSize, universeSize);
            for (var i = 0; i < extractedData.length; i++)
            {
                imageData.data[i] = extractedData[i];
            }
            ctx.putImageData(imageData, 0, 0);

            var realCtx = document.getElementById("gameCanvas").getContext("2d");

            realCtx.imageSmoothingEnabled = false;
            realCtx.mozImageSmoothingEnabled = false;
            realCtx.webkitImageSmoothingEnabled = false;
            realCtx.clearRect(0, 0, canvasWidth, canvasHeight);
            realCtx.drawImage(c, 0, 0);

            currentRenderedFrame = frameNumber;
            document.getElementById("currentTurn").innerHTML = currentRenderedFrame;
        };

        goToStart = function ()
        {
            if (isPlaying) togglePlay();

            drawFrame(0);
        };

        drawNextFrame = function ()
        {
            if (currentRenderedFrame >= frameArray.length - 1)
            {
                if (isPlaying) togglePlay();
            }
            else
            {
                drawFrame(currentRenderedFrame + 1);
            }
        };

        togglePlay = function ()
        {
            if (!isPlaying)
            {
                playInterval = setInterval(drawNextFrame, delay);
            }
            else
            {
                clearInterval(playInterval);
            }
            isPlaying = !isPlaying;
        };

        increaseSpeed = function ()
        {
            delay = Math.round((2 * delay) / 3);
            if (isPlaying)
            {
                togglePlay();
                togglePlay();
            }
        };

        decreaseSpeed = function ()
        {
            delay = Math.round(delay * 1.5)
            if (isPlaying)
            {
                togglePlay();
                togglePlay();
            }
        };

        ws.onopen = function ()
        {
            var canvasHeight = document.getElementById("gameCanvas").height;
            var canvasWidth = document.getElementById("gameCanvas").width;
            currentTime = new Date();
            document.getElementById("preCanvas").height = universeSize;
            document.getElementById("preCanvas").width = universeSize;
            document.getElementById("gameCanvas").getContext("2d").scale(canvasWidth / universeSize, canvasHeight / universeSize);
            ws.send("${game.id.toString()}");
        };

        ws.onmessage = function (binaryMessage)
        {
            frameArray[currentTurn++] = binaryMessage;
            document.getElementById("loadedTurns").innerHTML = currentTurn;

            if (currentTurn >= ${game.players.turns.flatten().size()})
            {
                document.getElementById("gameView").hidden = "";
                drawFrame(0);
            }
        };
    </script>
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
<div>
    Players:
    <g:each in="${game.players.sort { it.agent.team.id }}" var="matchPlayer" status="i">
        <span style="color: ${GameConstants.getRGB(i)}">${matchPlayer.agent.team.username} (<a
                href="/player-outputs/${matchPlayer.outputFileName}">View log</a>)</span>
    </g:each><br/>
    Winner: ${game.players.every { it.outcome.equals(Outcome.DRAW) } ? "Draw" : game.players.find { it.outcome.equals(Outcome.WIN) }.agent.with { it.team.username + " (" + it.fqClassName + ")" }}<br/>
    Turns to complete: ${game.players.turns.flatten().size()}<br/>
    Loading turn data: <span id="loadedTurns">0</span> out of ${game.players.turns.flatten().size()}
</div>

<div id="gameView" hidden="hidden">
    <canvas id="gameCanvas" style="border: 1px solid black;" width="600" height="600"></canvas>

    <div>
        <button onclick="goToStart();">|&lt;</button>
        <button onclick="drawFrame(--currentRenderedFrame);">&lt;</button>
        <button onclick="togglePlay();">Play / pause</button>
        <button onclick="drawFrame(++currentRenderedFrame);">&gt;</button>
        <button onclick="decreaseSpeed();">Decrease speed</button>
        <button onclick="increaseSpeed();">Increase speed</button>
        Current displayed turn: <span id="currentTurn"></span>
    </div>
</div>

<canvas id="preCanvas" hidden="hidden"></canvas>
</body>
</html>