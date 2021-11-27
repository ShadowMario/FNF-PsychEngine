var express = require('express');
var mongojs = require('mongojs');
var jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const tf = require('@tensorflow/tfjs-node');
const nsfw = require('nsfwjs');
const fs = require("fs");

// using node.js 14.17.5 LTS 
// run npm install

var app = express();

var username = "";

app.db = mongojs('game_server', ['scores', 'users']);

app.use(express.urlencoded({extended:false}));
app.use(express.json());
dotenv.config();

async function checkNsfw(pic) {
    const model = await nsfw.load();
    const image = await tf.node.decodeImage(pic.data,3);
    const predictions = await model.classify(image);
    image.dispose(); 
    console.log(predictions);
    var isPorn = false;
    return predictions;
}

function generateAccessToken(username) {
    return jwt.sign(username, process.env.TOKEN_SECRET, { expiresIn: '1800s' });
}

function authenticateToken(req, res, next) {
    token = req.body.token;
  
    if (token == null) return res.sendStatus(401);
  
    jwt.verify(token, process.env.TOKEN_SECRET, (err, user) => {
      console.log(err);
  
      if (err) return res.sendStatus(403);
  
      username = user.username;
    });
}

app.post("/submitScore", function(req, res)
    {
        if(!req.body.score)
        {
            res.send({error:"No score value was submitted"});
            return;
        }
        var daSongRawBody = {
            score: req.body.score,
            song: req.body.song,
            difficulty: req.body.difficulty,
            token: req.body.token
        };
        console.log(daSongRawBody);
        console.log(req.body);

        authenticateToken(req, res);

        var daSongBody = {
            score: daSongRawBody.score,
            song: daSongRawBody.song,
            difficulty: daSongRawBody.difficulty,
            username: username
        }
        app.db.scores.insert(daSongBody, function(err)
        {
            if(err)
            {
                console.log("Failed to insert score: " + err);
                res.send({error:"Internal Server Error"});
                return;
            }
            res.send({success:true});
        });
    });

app.post("/highScores", function(req, res)
{
    console.log(req.body);
    //console.log(JSON.parse(req.body).song);
    //var requestd = JSON.parse(req.body);
    app.db.scores.find({song: /*requestd.song*/'roses', difficulty: /*requestd.difficulty*/2}, {_id:0}).sort({score:-1}).limit(10, function(err, result)
    {
        if(err)
        {
            console.log("Failed to find scores: " + err);
            res.send({error:"Internal Server Error"});
            return;
        }
        var scores = [];
        var players = [];

        for(var i=0; result && i<result.length; i++)
        {
            scores.push(result[i].score);
            players.push(result[i].username);
        }
        res.send({success:true, scores:scores, players:players});
    });
});

app.post("/login", function(req, res)
{
    if(!req.body.username || !req.body.password)
    {
        res.send({error: "Missing username or password", token: null})
        console.log('Missing username or password');
        return;
    }
    var daLoginThing = {
        username: req.body.username,
        password: req.body.password
    };

    console.log(daLoginThing);
    
    app.db.users.find(daLoginThing, function(err, result)
    {
        if(err)
        {
            res.send({error: "Internal server error", token: null});
            return;
        }else {
            if(result.length > 0)
            {
                result.forEach(account => {
                    if(account.username && account.password)
                    {
                        const token = generateAccessToken({username: daLoginThing.username});
                        res.send({token: token});
                        console.log('success');
                    }else
                    {
                        res.send({error: "Account not found in the database", token: null});
                    }
                });
            }else
            {
                res.send({error: "Account not found in the database", token: null});
            }
        }
    });
});

app.post("/register", function(req, res)
{
    if(!req.body.username || !req.body.password)
    {
        res.send({error:"No username or password was submitted"});
        return;
    }
    var daRegisterThing = {
        username: req.body.username,
        password: req.body.password
    };
    
    app.db.users.find(daRegisterThing.username, function(err, result)
    {
        if(err)
        {
            res.send({error: "Internal server error"});
            return;
        }else {
                var num = 0;
                var canSend = true;
                result.forEach(account => {
                    if(account.username == daRegisterThing.username)
                    {
                        canSend = false;
                        num = 0;
                        res.send({error: "Account with the same name alredy exists", token: null});
                        return;
                    }else
                    {
                        num++;
                        console.log(num);
                    }
                });
                console.log(result);
                if(num == result.length && canSend)
                {
                    app.db.users.insert(daRegisterThing, function (err) {
                        if(err)
                        {
                            console.log(err);
                        }else
                        {
                            const token = generateAccessToken({username: daRegisterThing.username});
                            res.send({token: token});
                        }
                    });
                }
        }
    });
});

app.post("/publishLevel", function(req, res) 
{
    // TODO: Post levels
})

app.post("/rateLevel", function(req, res) 
{
    // TODO: Rate Levels
});

app.post("/postImg", function(req, res) {
    if(checkNsfw(Buffer.from(req, "base64")))
    {
        res.send({error: 'STOP POSTING PORN!11!1!😡😡😡'});
    }else
    {
        res.send({success: true});
    }
});

var server = app.listen(2000, function()
{ 
    console.log('Listening on port %d', server.address().port);
    //console.log(require('crypto').randomBytes(64).toString('hex'));
});