// const anime = require('../node_modules/animejs/lib/anime.es.js');
// import anime from '../node_modules/animejs/lib/anime.es.js';

$(document).ready(()=>{

    $(".sidebarShow").click(async ()=>{ 
        anime({
            targets: '.sidebar',
            width: {
                value: ['0%', '30%'], duration: 1000
            }
        });
    })

    $(".sidebarHide").click(async ()=>{ 
        anime({
            targets: '.sidebar',
            width: {
                value: ['30%', '0%'], duration: 1000
            }
        });
    });
    
})