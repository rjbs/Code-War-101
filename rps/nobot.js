#!/usr/bin/env node

var readline = require('readline');

var inited = false;
var plays = new Object();
var counters = { 'rock':'paper', 'paper':'scissors', 'scissors':'rock' };
var lastplay = -1;

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

rl.on('line', function (cmd) {
  if(cmd === 'init' && !inited) {
    console.log(move(null));
    inited = true;
  }
  else if(inited) {
    var results = cmd.split(' ');
    if(plays[results[1]]) {
      plays[results[1]] = plays[results[1]] + 1;
    }
    else {
      plays[results[1]] = 1;
    }
    console.log(move(results[1]));
  }
});

var move = function(played) {
  var available_plays = ['rock','paper','scissors'];

  lastplay = lastplay + 1;
  if(lastplay >= 3) {
    lastplay = 0;
  }

  if(!inited || (!counters[played])) {
    return counters[available_plays[lastplay]];
  }
  var mostPlayed = Object.keys(plays).sort(function(a, b) { return (plays[b] - plays[a])});
  if(mostPlayed[0] - mostPlayed[1] > 5) {
    return counters[mostPlayed[0]];
  }

  return counters[available_plays[lastplay]];
};
