jQuery(document).ready(function($) {
    $('.ActiveButton').click(function(event) {
        $(this).removeClass('gizle')
        $(this).find('i').fadeIn('fast');
    });
    
    $('#button-load').click(function(event) {
        $('.ActiveButton').addClass('gizle');
        $(this).html(`<img src="${PLUGIN_ROOT}img/loading.svg" /> Loading...`);
        $(this).css('background-image', 'none');
        $('.ActiveButton').removeClass('gizle');

        $('body').addClass('active');
        document.querySelector("#model-viewer").addEventListener('progress', (event) => {
            $('.percentage small').html( (event.detail.totalProgress*100).toFixed(4) + '%');
            if(event.detail.totalProgress==1){
                console.log('Progress End!')
                setTimeout(function(){
                    $('body').removeClass('active');
                },250);
            }
        });
    });
});

document.querySelector("#model-viewer").addEventListener('ar-status', (event) => {
    if(event.detail.status === 'failed'){
        let error = document.querySelector("#error");
            error.classList.remove('hide');
            error.addEventListener('transitionend',(event) => {
                error.classList.add('hide');
            });
    }
});