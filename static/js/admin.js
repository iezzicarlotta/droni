const btnLogin = document.getElementById('btnLogin');
const mailInput = document.getElementById('mail');
const passInput = document.getElementById('password');
const loginForm = document.getElementById('loginForm');
const adminPanel = document.getElementById('adminPanel');
const dronesList = document.getElementById('dronesList');
const pilotsList = document.getElementById('pilotsList');
const adminMessage = document.getElementById('adminMessage');
const btnLogout = document.getElementById('btnLogout');
const refreshDrones = document.getElementById('refreshDrones');
const refreshPilots = document.getElementById('refreshPilots');

// API key removed from client-side; authorization uses server-side session (set at login)

async function doLogin() {
  adminMessage.textContent = '';
  const body = { mail: mailInput.value, password: passInput.value };
  try {
  const res = await fetch('/api/login', { method: 'POST', credentials: 'same-origin', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    const data = await res.json();
    if (!data.success) {
      adminMessage.textContent = data.error || 'Login failed';
      return;
    }
    // show admin panel
    loginForm.style.display = 'none';
    adminPanel.style.display = 'block';
    btnLogout.style.display = 'inline-block';
    await loadDrones();
    await loadPilots();
  } catch (e) {
    console.error(e);
    adminMessage.textContent = 'Errore di rete durante login';
  }
}

function renderTable(container, data, columns){
  if(!data || !data.length){ container.innerHTML = '<div class="card p-3 small-muted">Nessun dato</div>'; return; }
  let html = '<div class="card p-2"><table class="table table-striped" style="margin:0"><thead><tr>' + columns.map(c=>`<th>${c.label}</th>`).join('') + '</tr></thead><tbody>';
  for(const row of data){
    html += '<tr>' + columns.map(c=>`<td>${(row[c.key]!==undefined?row[c.key]:'')}</td>`).join('') + '</tr>';
  }
  html += '</tbody></table></div>';
  container.innerHTML = html;
}

async function loadDrones(){
  try{
  const res = await fetch('/api/admin/drones', { credentials: 'same-origin' });
    const data = await res.json();
    if(!data.success){ adminMessage.textContent = data.error; return; }
    renderTable(dronesList, data.data, [{label:'ID',key:'ID'},{label:'Modello',key:'modello'},{label:'Capacità',key:'capacità'},{label:'Batteria',key:'batteria'}]);
  }catch(e){ console.error(e); adminMessage.textContent='Errore caricamento droni'; }
}

async function loadPilots(){
  try{
  const res = await fetch('/api/admin/pilots', { credentials: 'same-origin' });
    const data = await res.json();
    if(!data.success){ adminMessage.textContent = data.error; return; }
    renderTable(pilotsList, data.data, [{label:'ID',key:'ID'},{label:'Nome',key:'nome'},{label:'Cognome',key:'cognome'},{label:'Turno',key:'turno'},{label:'Brevetto',key:'brevetto'}]);
  }catch(e){ console.error(e); adminMessage.textContent='Errore caricamento piloti'; }
}

async function doLogout(){
  try{
  await fetch('/api/logout', { method:'POST', credentials: 'same-origin' });
  }catch(e){ }
  loginForm.style.display = 'block'; adminPanel.style.display='none'; btnLogout.style.display='none';
}

btnLogin.addEventListener('click', doLogin);
passInput.addEventListener('keyup', (e) => { if (e.key === 'Enter') doLogin(); });
btnLogout.addEventListener('click', doLogout);
refreshDrones && refreshDrones.addEventListener('click', loadDrones);
refreshPilots && refreshPilots.addEventListener('click', loadPilots);