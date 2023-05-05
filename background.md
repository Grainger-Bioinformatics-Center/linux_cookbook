# Running programs in background #
Version 0.1 (not tested - use at your own risk)

If you want to keep your programs active even if you close the terminal, they have to be running in the background.

## Method 1 ##

### Starting a program in the background ###
Add an ampersand to your command line:
~~~
<command> &
~~~

### Bring active job into the background (short) ###
1. Stop active foreground job with (Ctrl)+z  
2. Type `bg`


### Bring active job into the background (longer) ###
1. Stop active foreground job with (Ctrl)+z  
2. List all of your jobs with `jobs`  
3. Restart with `bg %<#>` job number <#> in the background  

in addition, you can:  
- Use `fg %<#>` to bring back job number <#> into the foreground  
- Use `kill %<#>`to stop job number <#>  

Note: a job that runs in the background cannot be brought back into the foreground after you have closed the terminal

## Method 2 ##

### Use command 'screen' ###

