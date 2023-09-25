module openai_api
    use json_module
    implicit none
    contains

    !Get API Key Subroutine
    subroutine GetAPIKey(apikey)
        implicit none
        integer :: err
        character(len=80),intent(out) :: apikey
        
        call get_environment_variable('OPENAI_API_KEY',value=apikey,status=err)
        if (err /= 0) then
            print *,"API Key environment variable (OPENAI_API_KEY) not set!"
            stop 1
        end if
    end subroutine GetAPIKey

    !Get Completion from API Subroutine
    subroutine GetAPICompletion(apikey,query)
        implicit none
        integer :: err
        integer, parameter :: iunit = 10
        character(len=80),intent(in) :: apikey
        character(len=2048),intent(in) :: query
        character(len=4096) :: curlcmd
        character(len=1024) :: line

        curlcmd = 'curl -s https://api.openai.com/v1/chat/completions ' &
            // '-H "Content-Type: application/json" ' &
            // '-H "Authorization: Bearer ' // trim(apikey) // '" ' &
            // '-d ''{"model": "gpt-4", "messages":[{"role": "user", "content": "' &
            // trim(query) // '"}], "temperature":0.7}'' > tmpout.json'

        print *,"Curl: ",trim(curlcmd)
        call execute_command_line(trim(curlcmd),exitstat=err)
    end subroutine GetAPICompletion

    !Extract JSON Subroutine
    subroutine ExtractJSON(msg)
        implicit none
        type(json_file) :: json
        type(json_core) :: jcore
        type(json_value), pointer :: choicesPtr, choicePtr, indexPtr, messagePtr, contentPtr
        integer :: index,created,err
        logical :: found
        character(kind=json_ck,len=:),allocatable,intent(out) :: msg

        !Test JSON extraction
        call json%initialize()
        call json%load(filename='tmpout.json')

        !Get the message
        call json%get('created',created,found)

        call json%get_core(jcore)
        call json%get('choices',choicesPtr)
        call jcore%get_child(choicesPtr,1,choicePtr)
        call jcore%get_child(choicePtr,'index',indexPtr,found)
        call jcore%get(indexPtr,index)
        call jcore%get_child(choicePtr,'message',messagePtr,found)
        call jcore%get_child(messagePtr,'content',contentPtr,found)
        call jcore%get(contentPtr,msg)

        call execute_command_line('rm tmpout.json',exitstat=err)
        !call json%get('choices[0].message.content',message,found)
    end subroutine ExtractJSON
end module openai_api