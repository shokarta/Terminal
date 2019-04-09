function keyboardListener(key) {
    if (viewMode==='common') {
        if (cardTemporar===undefined) {
            cardTemporar = String.fromCharCode(key);
        }
        else {
            cardTemporar = cardTemporar + String.fromCharCode(key);
        }
    }
}
function cardAssign() {
    if (cardTemporar!==undefined) {
        if (cardTemporar.length===10) {
            login(cardTemporar);
        }
    }
}

function cardInfo(vcard) {
    if(vcard===null) { return null; }
    else {
        var vname = sql.selectName(vcard);
        if(vname==="NULL") { statusLabel.color=colors['cardDisplay']; return vcard; }
        else { statusLabel.color=colors['nameDisplay']; return vname; }
    }
}

function passKeyPressed(key) {
         if(key==="C") {
             passTypedValue = "";
         }
    else if(key==="B")
         {
             if(passTypedValue.length>0) { passTypedValue = passTypedValue.substring(0, passTypedValue.length-1); }
         }
    else {
             passTypedValue = passTypedValue + key;
         }
}
function aplKeyPressed(key) {
         if(key==="C") {
             aplTypedValue = "";
         }
    else if(key==="B")
         {
             if(aplTypedValue.length>0) { aplTypedValue = aplTypedValue.substring(0, aplTypedValue.length-1); }
         }
    else {
             aplTypedValue = aplTypedValue + key;
         }
}

function checkDB() {
    if(sql.checkConnection()===true) {
        dbOnline = true;
    }
    else {
        dbOnline = false;
    }
}

function createDB() {
    // open database connection
     db = LocalStorage.openDatabaseSync(dbId, dbVersion, dbDescription, dbSize);

     // create table for profile if doesnt exists yet
     db.transaction(function(tx) { tx.executeSql('CREATE TABLE IF NOT EXISTS `offlineRecords` ('
                                                 + 'id INTEGER PRIMARY KEY AUTOINCREMENT,'
                                                 + 'card VARCHAR(10) NOT NULL,'
                                                 + 'apl VARCHAR(16) NOT NULL,'
                                                 + 'taskType VARCHAR(16) NOT NULL,'
                                                 + 'taskKind VARCHAR(16) NOT NULL,'
                                                 + 'time INTEGER NOT NULL)'); });
}
function offlineDB(v_card, v_apl, v_taskType, v_taskKind, v_timestamp) {
    createDB();
    // open database connection
    db = LocalStorage.openDatabaseSync(dbId, dbVersion, dbDescription, dbSize);

    db.transaction(function(tx) {
        var sql = 'INSERT INTO `offlineRecords` (card, apl, taskType, taskKind, time) VALUES (\'' + v_card + '\',\'' + v_apl + '\',\'' + v_taskType + '\',\'' + v_taskKind + '\',' + v_timestamp + ')';
        tx.executeSql(sql);
    });
}

function updateOnlineDB() {
    // SHOKARTA - jak a kde použít?
    createDB();
    // open database connection
    db = LocalStorage.openDatabaseSync(dbId, dbVersion, dbDescription, dbSize);

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT id, card, apl, taskType, taskKind, time FROM `offlineRecords` ORDER BY id ASC');
        var ix;
        for (ix = 0; ix< rs.rows.length; ++ix) {
            if(sql.checkRecord(rs.rows.item(ix).card,rs.rows.item(ix).apl,rs.rows.item(ix).taskType,rs.rows.item(ix).taskKind,rs.rows.item(ix).time)===true) {
                db.transaction(function(tx2) { tx2.executeSql('DELETE FROM `offlineRecords` WHERE id=' + rs.rows.item(ix).id); });
            }
                else {
                if(sql.insertRecord(rs.rows.item(ix).card,rs.rows.item(ix).apl,rs.rows.item(ix).taskType,rs.rows.item(ix).taskKind,rs.rows.item(ix).time)===true) {
                    db.transaction(function(tx2) { tx2.executeSql('DELETE FROM `offlineRecords` WHERE id=' + rs.rows.item(ix).id); });
                }
                else {
                    break;
                }
            }
        }
    });
}

function statusDisplay() {
  if(statusWarning.running===false) {
    if (card===null) {
        status.color = colors['initialStatus'];
        status.text = "Přiložte kartu";
        //return "Přiložte kartu";
    }
    else if ((card!==null) && (taskType===null || taskKind===null)) {
        resetTerminal.interval = 10000;
        resetTerminal.running = true;
        status.color = colors['chooseTask'];
        status.text = "Vyberte zadání";
        //return "Vyberte zadání";
    }
    else {
        // SQL Insert
        checkDB();
        var timestamp = Math.floor(Date.now() / 1000);
        if(sql.insertRecord(card, apl, taskType, taskKind, timestamp)===false) { offlineDB(card, apl, taskType, taskKind, timestamp); }

        card=null;
        resetTerminal.interval = 3000;
        resetTerminal.running = true;
        status.color = colors['recordSaved'];
        refreshCanvas();
        loggedOff = true;
        status.text = "Záznam uložen...";
        //return "Záznam uložen...";
    }
  }
}
function refreshCanvas() {
    leftCanvas1.requestPaint();
    leftCanvas2.requestPaint();
    rightCanvas1.requestPaint();
    rightCanvas2.requestPaint();
}
function logout() {
    card=null;
    taskType=null;
    taskKind=null;
    warningTriggered=false;
    //cardTemporar=undefined;
    startTime=0;
    refreshCanvas();
}

function alertDisplay() {
    if(statusWarning.running===true) {
        statusWarning.stop();
        warningTriggered = false;
        startTime = 0;
        statusWarning.restart();
    }
    else {
        statusWarning.restart();
    }
}

function doubleNumber(variable) {
    if (variable < 10) { variable = '0' + variable; }
    return variable;
}
function currentTime() {
    var today = new Date();
    var time = doubleNumber(today.getHours()) + ":" + doubleNumber(today.getMinutes()) + ":" + doubleNumber(today.getSeconds());
    return time;
}
function currentDate() {
    var today = new Date();
    var date = doubleNumber(today.getDate()) + '.' + doubleNumber((today.getMonth()+1)) + '.' + today.getFullYear();
    return date;
}



function login(cardinfo) {
    logout();
    cardTemporar = "";
    statusWarning.stop();
    card = cardinfo;
    startTime=0;
    resetTerminal.restart();
    //return card
}


function imgSource() {
    var src;
    if(viewMode==='common') { src='settings'; }
    else if(viewMode==='settings' || viewMode==='checkPass') { src='terminal'; }
    else { src='terminal'; }

    return 'sources/images/' + src + '.gif';
}
function viewModeChange(argument) {
    if(typeof argument==="undefined") {
        if(viewMode==='common') { viewMode='checkPass'; }
        else if(viewMode==='checkPass' || viewMode==='settings') { viewMode='common'; }
        else { viewMode='common'; }
    }
    else {
        if(argument==="aplChange") { viewMode='aplChange'; }
        else { viewMode = 'confirmShutdown'; }
    }
    icon.playing = true;
}
