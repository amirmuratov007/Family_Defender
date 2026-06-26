const canvas=document.querySelector("#net");
if(canvas){
  const ctx=canvas.getContext("2d");
  let points=[];
  let frame;
  function resize(){
    canvas.width=innerWidth*devicePixelRatio;
    canvas.height=innerHeight*devicePixelRatio;
    canvas.style.width=innerWidth+"px";
    canvas.style.height=innerHeight+"px";
    ctx.setTransform(devicePixelRatio,0,0,devicePixelRatio,0,0);
    const count=Math.min(110,Math.max(48,Math.floor(innerWidth/13)));
    points=Array.from({length:count},()=>({x:Math.random()*innerWidth,y:Math.random()*innerHeight,vx:(Math.random()-.5)*.28,vy:(Math.random()-.5)*.28}));
  }
  function draw(){
    ctx.clearRect(0,0,innerWidth,innerHeight);
    for(const p of points){
      p.x+=p.vx;p.y+=p.vy;
      if(p.x<-20)p.x=innerWidth+20;
      if(p.x>innerWidth+20)p.x=-20;
      if(p.y<-20)p.y=innerHeight+20;
      if(p.y>innerHeight+20)p.y=-20;
    }
    for(let i=0;i<points.length;i++)for(let j=i+1;j<points.length;j++){
      const a=points[i],b=points[j],d=Math.hypot(a.x-b.x,a.y-b.y);
      if(d<150){
        ctx.strokeStyle=`rgba(213,166,66,${(1-d/150)*.18})`;
        ctx.beginPath();ctx.moveTo(a.x,a.y);ctx.lineTo(b.x,b.y);ctx.stroke();
      }
    }
    for(const p of points){
      const g=ctx.createRadialGradient(p.x,p.y,0,p.x,p.y,10);
      g.addColorStop(0,"rgba(243,217,140,.9)");
      g.addColorStop(1,"rgba(213,166,66,0)");
      ctx.fillStyle=g;ctx.beginPath();ctx.arc(p.x,p.y,10,0,Math.PI*2);ctx.fill();
    }
    frame=requestAnimationFrame(draw);
  }
  resize();draw();
  addEventListener("resize",()=>{cancelAnimationFrame(frame);resize();draw();});
}
