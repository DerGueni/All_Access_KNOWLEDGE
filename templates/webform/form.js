(function(){
  const app=document.getElementById('app');

  // Host -> Web
  window.Bridge.on('load',(model)=>{
    app.innerHTML = '<pre>' + JSON.stringify(model,null,2) + '</pre>';
  });

  // Web -> Host example:
  // window.Bridge.callAccess('Ping',{});
})();
