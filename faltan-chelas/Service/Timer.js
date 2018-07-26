
console.log("Start Program");

var cancelTimer;

var timer = setInterval(function(){
    console.log("Repeated function");
    clearTimeout(cancelTimer);
    clearInterval(timer);
},2000);


cancelTimer = setTimeout(function(){
    console.log("CleaningInterval");
    clearInterval(timer);
},12000);
