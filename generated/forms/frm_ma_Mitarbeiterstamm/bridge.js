(function(){
  const listeners = new Map();
  function emit(type,payload){ (listeners.get(type)||[]).forEach(fn=>fn(payload)); }
  function on(type,fn){ if(!listeners.has(type)) listeners.set(type,[]); listeners.get(type).push(fn); }

  async function callAccess(method,args){
    const msg={ kind:'call', method, args:args||{}, v:'' };
    if (window.chrome && window.chrome.webview && window.chrome.webview.postMessage) {
      window.chrome.webview.postMessage(msg);
      return true;
    }
    console.warn('WebView2 bridge not available (host dependent).');
    return false;
  }

  if (window.chrome && window.chrome.webview) {
    window.chrome.webview.addEventListener('message',(e)=>{
      const m=e.data||{};
      if(m.kind==='event') emit(m.type,m.payload);
    });
  }

  window.Bridge = { on, callAccess };
})();
