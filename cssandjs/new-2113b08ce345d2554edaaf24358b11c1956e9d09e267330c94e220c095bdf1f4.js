Feedback={init:function(){this.bindEvents(),hide_feedback()},bindEvents:function(){var e=this;$("#hide_feedback").on("click",function(){hide_feedback()}),$("#submit_feedback").on("click",function(){show_feedback()}),$(".feedback-form").on("submit",function(){e.disable_submit_feedback_buttons()})},disable_submit_feedback_buttons:function(){var e=$("#feedback_form");return is_mobile()?MobileLoader.show():Loader.show(e),e.find(":submit, :reset").attr("disabled",!0).prop("disabled",!0),!0}},$(function(){Feedback.init()});