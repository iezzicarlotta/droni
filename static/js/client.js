const btn = document.getElementById('btnFetch');
const btnRefresh = document.getElementById('btnRefresh');
const orderIdInput = document.getElementById('orderId');
const orderInfo = document.getElementById('orderInfo');
const orderDetails = document.getElementById('orderDetails');
const mapContainer = document.getElementById('mapContainer');
const msg = document.getElementById('message');
const skeletonWrap = document.getElementById('skeleton');
const lastUpdatedEl = document.getElementById('lastUpdated');

let map; let polyline; let marker; let lastUpdated = null;
let pollingInterval = null; let currentMissionId = null;

function setLoading(on){
  if(on){
    skeletonWrap.style.display='block';
    orderInfo.style.display='none';
    mapContainer.style.display='none';
    btn.disabled = true; btnRefresh.disabled = true; orderIdInput.disabled = true;
  } else {
    skeletonWrap.style.display='none';
    btn.disabled = false; btnRefresh.disabled = false; orderIdInput.disabled = false;
  }
}

function initMap() {
  if (map) return;
  map = L.map('map').setView([45.4642, 9.19], 13);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
}

async function fetchOrder(id, opts = {}) {
  msg.textContent = '';
  setLoading(true);
  try {
  const res = await fetch(`/api/order/${id}`, { credentials: 'same-origin' });
    const data = await res.json();
    if (!data.success) {
      msg.textContent = data.error || 'Errore';
      setLoading(false);
      return;
    }
    orderInfo.style.display = 'block';
    const o = data.data;
    orderDetails.innerHTML = `
      <p><strong>ID:</strong> ${o.ID}</p>
      <p><strong>Tipo:</strong> ${o.tipo}</p>
      <p><strong>Peso totale:</strong> ${o.peso_totale}</p>
      <p><strong>Orario:</strong> ${o.orario}</p>
      <p><strong>Indirizzo:</strong> ${o.indirizzo_destinazione}</p>
      <p><strong>Stato missione:</strong> ${o.stato_missione || 'N/A'}</p>
    `;

    if (o.id_missione) {
        await fetchTraces(o.id_missione);
        currentMissionId = o.id_missione;
        // start polling
        if (pollingInterval) clearInterval(pollingInterval);
        pollingInterval = setInterval(()=>{ fetchTraces(currentMissionId); }, 10000);
        // show rating area only if mission completed
        document.getElementById('ratingArea').style.display = (o.stato_missione === 'completata') ? 'block' : 'none';
    } else {
      mapContainer.style.display = 'none';
    }
    lastUpdated = new Date();
    lastUpdatedEl.textContent = 'Ultimo aggiornamento: ' + lastUpdated.toLocaleTimeString();
  } catch (e) {
    console.error(e);
    msg.textContent = 'Errore di rete';
  } finally {
    setLoading(false);
  }
}

async function fetchTraces(missionId) {
  initMap();
  try {
  const res = await fetch(`/api/mission/${missionId}/traces`, { credentials: 'same-origin' });
    const data = await res.json();
    if (!data.success) {
      msg.textContent = data.error || 'Errore recupero tracce';
      return;
    }
    const coords = data.data.map(r => [parseFloat(r.latitudine), parseFloat(r.longitudine)]);
    if (!coords.length) {
      msg.textContent = 'Nessuna traccia trovata';
      return;
    }
    mapContainer.style.display = 'block';
    if (polyline) map.removeLayer(polyline);
    if (marker) map.removeLayer(marker);
    polyline = L.polyline(coords, { color: '#d63384' }).addTo(map);
    marker = L.circleMarker(coords[coords.length-1], { radius:8, fillColor:'#d63384', color:'#fff', weight:2 }).addTo(map);
    map.fitBounds(polyline.getBounds(), { padding: [50,50] });
  } catch (e) {
    console.error(e);
    msg.textContent = 'Errore recupero tracce';
  }
}

btn.addEventListener('click', () => {
  const id = orderIdInput.value.trim();
  if (!id) return; fetchOrder(id);
});

// Show logged-in user's orders (requires login via /api/login elsewhere)
const btnMyOrders = document.getElementById('btnMyOrders');
async function showMyOrders(){
  msg.textContent = '';
  setLoading(true);
  try{
    const res = await fetch('/api/my_orders', { credentials: 'same-origin' });
    const data = await res.json();
    if(!data.success){ msg.textContent = data.error || 'Errore'; setLoading(false); return; }
    // render simple list
    orderInfo.style.display = 'block';
    mapContainer.style.display = 'none';
    let html = '<h4>I miei ordini</h4>';
    if(!data.data.length) html += '<div class="card p-3 small-muted">Nessun ordine</div>';
    else{
      html += '<div class="list-group">';
      for(const o of data.data){
        html += `<div class="list-group-item"><strong>ID ${o.ID}</strong> — ${o.tipo} — Stato: ${o.stato_missione || 'N/A'} — Orario: ${o.orario}</div>`;
      }
      html += '</div>';
    }
    orderDetails.innerHTML = html;
  }catch(e){ console.error(e); msg.textContent='Errore di rete'; }
  finally{ setLoading(false); }
}

btnMyOrders && btnMyOrders.addEventListener('click', showMyOrders);

// Client login UI
const btnClientLogin = document.getElementById('btnClientLogin');
const btnClientLogout = document.getElementById('btnClientLogout');
const clientMail = document.getElementById('clientMail');
const clientPassword = document.getElementById('clientPassword');
const clientLoginMsg = document.getElementById('clientLoginMsg');

async function clientDoLogin(){
  clientLoginMsg.textContent = '';
  try{
    const res = await fetch('/api/login', { method:'POST', credentials:'same-origin', headers:{'Content-Type':'application/json'}, body: JSON.stringify({ mail: clientMail.value, password: clientPassword.value }) });
    const data = await res.json();
    if(!data.success){ clientLoginMsg.textContent = data.error || 'Login fallito'; return; }
    btnClientLogin.style.display = 'none'; btnClientLogout.style.display = 'inline-block';
    clientLoginMsg.textContent = 'Login effettuato come ' + data.user.nome;
  }catch(e){ console.error(e); clientLoginMsg.textContent = 'Errore di rete'; }
}

async function clientDoLogout(){
  try{ await fetch('/api/logout', { method:'POST', credentials:'same-origin' }); }catch(e){}
  btnClientLogin.style.display = 'inline-block'; btnClientLogout.style.display = 'none';
  clientLoginMsg.textContent = 'Logout effettuato';
}

btnClientLogin && btnClientLogin.addEventListener('click', clientDoLogin);
btnClientLogout && btnClientLogout.addEventListener('click', clientDoLogout);

btnRefresh.addEventListener('click', () => {
  const id = orderIdInput.value.trim(); if (!id) return; fetchOrder(id, { refresh:true });
});

orderIdInput.addEventListener('keyup', (e) => { if (e.key === 'Enter') btn.click(); });

// Rating submit
const btnSubmitRating = document.getElementById('btnSubmitRating');
const ratingValue = document.getElementById('ratingValue');
const ratingComment = document.getElementById('ratingComment');
const ratingMsg = document.getElementById('ratingMsg');

btnSubmitRating && btnSubmitRating.addEventListener('click', async () => {
  if (!currentMissionId) { ratingMsg.textContent = 'Nessuna missione selezionata'; return; }
  const valut = parseInt(ratingValue.value);
  const comment = ratingComment.value.trim();
  try{
  const res = await fetch(`/api/mission/${currentMissionId}/rating`, { method:'POST', credentials: 'same-origin', headers: { 'Content-Type':'application/json' }, body: JSON.stringify({ valutazione: valut, commento: comment }) });
    const data = await res.json();
    if (!data.success) { ratingMsg.textContent = data.error || 'Errore invio valutazione'; return; }
    ratingMsg.textContent = 'Valutazione inviata, grazie!';
  }catch(e){ console.error(e); ratingMsg.textContent = 'Errore di rete'; }
});