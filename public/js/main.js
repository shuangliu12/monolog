$(".show_all").hide();


$(document).ready(function(){
    $(".select_mood").click(function(){
        $(this).fadeOut('fast');
        $(".show_all").show();
    });
})


