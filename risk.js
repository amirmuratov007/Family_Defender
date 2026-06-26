function runRiskDemo(config){
  const input=document.querySelector('#dialogInput');
  const scoreNum=document.querySelector('#scoreNum');
  const scoreTitle=document.querySelector('#scoreTitle');
  const scoreText=document.querySelector('#scoreText');
  const chips=document.querySelector('#chips');
  const analyzeBtn=document.querySelector('#analyzeBtn');
  const safeBtn=document.querySelector('#safeBtn');
  const triggers=config.triggers;
  function analyze(){
    const text=input.value.toLowerCase();
    const found=triggers.filter(group=>group.words.some(word=>text.includes(word)));
    let score=found.reduce((sum,group)=>sum+group.weight,0);
    if(found.some(g=>g.id==='secrecy')&&found.some(g=>g.id==='money'))score+=12;
    if(found.some(g=>g.id==='access')&&found.some(g=>g.id==='urgency'))score+=10;
    score=found.length?Math.min(99,score):7;
    const level=score>=80?config.levels.high:score>=50?config.levels.medium:score>=25?config.levels.low:config.levels.safe;
    scoreNum.textContent=score;
    scoreTitle.textContent=level.title;
    scoreText.textContent=level.text;
    chips.innerHTML=found.length?found.map(g=>`<span class="chip">${g.label} +${g.weight}</span>`).join(''):`<span class="chip">${config.noTriggers}</span>`;
  }
  analyzeBtn.addEventListener('click',analyze);
  safeBtn.addEventListener('click',()=>{input.value=config.safeExample;analyze();});
  analyze();
}