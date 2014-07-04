# TODO pretty big kludge, just until we get kiosk UI up to same versions of gems as desktop/default
unless ENV['UI_MODE']=='kiosk'

  # Use this setup block to configure all options available in SimpleForm.
  SimpleForm.setup do |config|
    config.error_notification_class = 'alert alert-danger'
    config.button_class = 'btn btn-default'
    config.boolean_label_class = nil

    config.wrappers :vertical_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label, class: 'control-label'

      b.wrapper tag: 'div' do |ba|
        ba.use :input, class: 'form-control'
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :vertical_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label, class: 'control-label'

      b.wrapper tag: 'div' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :vertical_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.wrapper tag: 'div', class: 'checkbox' do |ba|
        ba.use :label_input
      end

      b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end

    config.wrappers :vertical_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label_input
      b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end

    # ======================

    config.wrappers :horizontal_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label, class: 'col-sm-3 control-label'

      b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input, class: 'form-control'
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :horizontal_labelless_select, tag: 'div', class: 'form-group zero-horizontal-margin', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :input, class: 'form-control'
      b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
    end

    config.wrappers :horizontal_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label, class: 'col-sm-3 control-label'

      b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :horizontal_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.wrapper tag: 'div', class: 'col-sm-offset-3 col-sm-9' do |wr|
        wr.wrapper tag: 'div', class: 'checkbox' do |ba|
          ba.use :label_input, class: 'col-sm-9'
        end

        wr.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        wr.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :horizontal_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.use :label, class: 'col-sm-3 control-label'

      b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    # ======================
    # For options page

    config.wrappers :h_opts_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label, class: 'col-sm-7 control-label'

      b.wrapper tag: 'div', class: 'col-sm-5' do |ba|
        ba.use :input, class: 'form-control'
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :h_opts_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label, class: 'col-sm-7 control-label'

      b.wrapper tag: 'div', class: 'col-sm-5' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :h_opts_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.wrapper tag: 'div', class: 'col-sm-offset-7 col-sm-5' do |wr|
        wr.wrapper tag: 'div', class: 'checkbox' do |ba|
          ba.use :label_input, class: 'col-sm-5'
        end

        wr.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        wr.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    config.wrappers :h_opts_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.use :label, class: 'col-sm-7 control-label'

      b.wrapper tag: 'div', class: 'col-sm-5' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    # currently only for trip planning Options page (for ARC only - use button-groups instead of radio-buttons to render boolean options)
    config.wrappers :h_opts_radio_button_groups, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.use :label, class: 'col-sm-7 control-label'

      b.wrapper tag: 'div', class: 'col-sm-5' do |ba|
        ba.use :input, wrap_with: { tag: 'div', class: 'btn-group' }

        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end

    # ==========================
    # For plan a trip page:

   config.wrappers :group, tag: 'div', class: "form-group", error_class: 'has-error',
        defaults: { input_html: { class: 'default-class'} }  do |b|

      b.use :html5
      b.use :min_max
      b.use :maxlength
      b.use :placeholder

      b.optional :pattern
      b.optional :readonly

      b.use :label, class: 'col-sm-3 control-label'

      b.wrapper tag: :div, class: 'col-sm-9' do |component|
        component.use :input, class: 'form-control', wrap_with: { class: "input-group" }
        component.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
        component.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
      end
    end

    config.wrappers :trip_dates, tag: 'div', class: 'col-md-6', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder
      # b.use :label, class: 'col-sm-7 control-label'

        b.use :input, class: 'form-control input-class'
        b.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        b.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      # b.wrapper tag: 'div', class: 'col-md-6 wrapper-class' do |ba|
      #   ba.use :input, class: 'form-control input-class'
      #   ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
      #   ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      # end
    end

    config.wrappers :plan_trip_radio, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
      b.use :html5
      b.use :placeholder

      b.use :label, class: 'col-sm-3 control-label'

      b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
        ba.use :input
        ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
        ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      end
    end


    # Wrappers for forms and inputs using the Bootstrap toolkit.
    # Check the Bootstrap docs (http://getbootstrap.com)
    # to learn about the different styles for forms and inputs,
    # buttons and other elements.
    config.default_wrapper = :vertical_form
  end

else

  # Use this setup block to configure all options available in SimpleForm.
  SimpleForm.setup do |config|
    config.wrappers :bootstrap, :tag => 'div', :class => 'control-group', :error_class => 'error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label
      b.wrapper :tag => 'div', :class => 'controls' do |ba|
        ba.use :input
        ba.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
        ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'help-block' }
      end
    end

    config.wrappers :prepend, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label
      b.wrapper :tag => 'div', :class => 'controls' do |input|
        input.wrapper :tag => 'div', :class => 'input-prepend' do |prepend|
          prepend.use :input
        end
        input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
        input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      end
    end

    config.wrappers :append, :tag => 'div', :class => "control-group", :error_class => 'error' do |b|
      b.use :html5
      b.use :placeholder
      b.use :label
      b.wrapper :tag => 'div', :class => 'controls' do |input|
        input.wrapper :tag => 'div', :class => 'input-append' do |append|
          append.use :input
        end
        input.use :hint,  :wrap_with => { :tag => 'span', :class => 'help-block' }
        input.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
      end
    end

    # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
    # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
    # to learn about the different styles for forms and inputs,
    # buttons and other elements.
    config.default_wrapper = :bootstrap
  end


end
