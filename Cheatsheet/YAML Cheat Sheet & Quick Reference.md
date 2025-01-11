<!DOCTYPE html>
<html class="scrollbar" translate="no" style="scroll-behavior: auto;"><head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8"><meta charset="utf-8"><meta http-equiv="X-UA-Compatible" content="IE=Edge,chrome=1"><meta http-equiv="content-language" content="en-gb"><meta name="renderer" content="webkit"><meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1"><meta name="app:pageurl" content="/"><title>YAML Cheat Sheet &amp; Quick Reference</title><meta name="keywords" content="reference,cheatsheet,code table,snippets,linux,config,format"><meta name="description" content="This is a quick reference cheat sheet for understanding and writing YAML format configuration files. "><meta property="og:url" content="https://quickref.me/yaml.html"><meta property="og:title" content="YAML Cheat Sheet &amp; Quick Reference"><meta property="og:site_name" content="QuickRef.ME"><meta property="og:description" content="This is a quick reference cheat sheet for understanding and writing YAML format configuration files. "><meta property="og:image" content="https://quickref.me/assets/image/yaml-preview.png?v=i7mjj"><meta property="og:image:width" content="2276"><meta property="og:image:height" content="1240"><meta property="og:type" content="website"><meta name="twitter:card" content="summary_large_image"><meta name="twitter:title" content="YAML Cheat Sheet &amp; Quick Reference"><meta name="twitter:site" content="@QuickRef.ME"><meta name="twitter:creator" content="@QuickRef.ME"><meta name="twitter:description" content="This is a quick reference cheat sheet for understanding and writing YAML format configuration files. "><meta name="twitter:image" content="https://quickref.me/assets/image/yaml-preview.png?v=jy7se"><link rel="icon" href="https://quickref.me/images/favicon.png?v=1"><link rel="icon shortcut" type="image/png" href="https://quickref.me/images/favicon.png?v=1"><link rel="canonical" href="https://quickref.me/yaml.html"><link rel="prefetch" href="https://quickref.me/"><link rel="prerender" href="https://quickref.me/"><link rel="alternate" href="https://quickref.me/atom.xml" title="QuickRef.ME" type="application/atom+xml"><link rel="stylesheet" href="YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference_files/style.css" media=""><script>
        if (localStorage.theme === 'dark' || (!('theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            let html = document.documentElement.classList;
            html.toggle('dark')
        }
    </script><script async="" src="YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference_files/google-analytics_analytics.js"></script><script>window.ramp=window.ramp||{},window.ramp.que=window.ramp.que||[]</script><script async="" src="YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference_files/ramp_config.js"></script><script>window._pwGA4PageviewId="".concat(Date.now()),window.dataLayer=window.dataLayer||[],window.gtag=window.gtag||function(){dataLayer.push(arguments)},gtag("js",new Date),gtag("config","G-6FCTS6QCRB",{send_page_view:!1}),gtag("event","ramp_js",{send_to:"G-6FCTS6QCRB",pageview_id:window._pwGA4PageviewId})</script></head><body class="bg-slate-100 dark:bg-slate-900"><header class=""><div class="max-container z-10"><div class="flex flex-row justify-between md:justify-start items-center py-3"><a href="https://quickref.me/" class="flex font-medium items-center justify-center md:justify-start text-slate-800 dark:text-slate-300"><div class="hidden md:flex justify-center w-10 h-10 md:w-12 md:h-12 text-white p-2 bg-emerald-500 rounded-full mr-3 text-2xl"><div class="self-center"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M303.55291933 951.35043811c-1.84934059-3.43448917-12.68119097-22.19208477-24.04142536-41.74225521l-20.07855218-35.4016586 5.01963776-9.51089265c2.90610631-5.01963776 13.20957383-23.24885049 22.9846585-40.15710664l17.70082986-31.17459456h366.69778034l6.86897834-11.09604238c3.43448917-6.34059549 13.73795669-23.77723335 22.72046763-39.10033977 8.71831893-15.32310642 22.19208477-38.30776491 29.85363797-51.51733873 7.66155321-12.94538297 16.37987214-28.00429739 19.02178646-33.02393629 2.90610631-5.28382976 14.00214869-24.30561621 24.56980821-42.27063694 10.56765952-18.22921273 29.85363797-51.51733987 43.06321181-73.97361551 12.94538297-22.45627563 35.93004146-62.08499826 51.25314787-87.71157333 15.05891442-25.89076594 28.53268025-49.93219015 29.85363797-53.63087132 3.43448917-8.98251093 8.45412693-8.18993607 12.94538184 2.11353259 2.11353145 4.4912549 8.71831893 16.90825501 14.79472355 26.94753166 6.34059549 10.30346752 20.60693618 35.13746773 32.23136143 55.48021077s25.62657394 44.38416953 30.91040369 53.63087133l9.77508466 16.64406414-6.07640462 9.77508466c-3.43448917 5.28382976-7.13317035 11.62442525-8.71831893 14.00214869-2.90610631 4.7554469-13.73795669 23.77723335-24.83399908 43.3274038-3.96287203 7.39736121-13.47376583 23.77723335-21.13531904 36.45842432-7.39736121 12.94538297-13.47376583 24.04142535-13.47376583 24.56980821 0 .79257486-3.43448917 6.34059549-7.39736121 12.41699898-4.22706403 6.07640462-9.51089379 15.32310642-12.15280811 20.34274531-2.37772345 5.01963776-6.86897835 12.94538297-9.77508465 17.17244587-2.64191431 4.4912549-5.81221262 10.03927666-6.60478749 12.68119096-1.05676573 2.37772345-2.64191431 4.4912549-3.69868117 4.49125604s-2.64191431 2.11353145-3.43448918 4.75544576c-1.05676573 2.37772345-5.28382976 10.56765952-9.77508466 17.70082987-4.22706403 7.39736121-10.56765952 17.96502073-13.47376582 23.77723335-3.17029831 5.81221262-10.83185038 19.28597845-17.17244587 29.58944597-6.34059549 10.56765952-11.62442525 20.07855331-11.62442525 21.13531904 0 .79257486-1.58514859 3.69868117-3.69868117 5.81221263-2.11353145 2.37772345-8.71831893 13.73795669-14.79472355 25.36238307s-18.22921273 33.81651001-26.94753053 49.66799815l-16.11568128 28.26848939H307.25159936l-3.69868003-5.81221263z"></path><path d="M523.88861725 694.82050674c-31.70297856-20.60693618-68.95397774-44.11997753-70.01074347-44.11997753-.79257486 0-10.03927666-5.81221262-20.60693618-13.20957383-10.83185038-7.13317035-22.72046763-14.53053155-26.68333966-16.11568128-3.69868117-1.84934059-6.86897835-3.96287203-6.86897835-5.01963776 0-.79257486-4.7554469-4.22706403-10.56765952-7.66155321l-10.30346752-5.81221262-.79257486-98.27923172c-.52838286-54.15925419 0-99.33599744.79257486-100.3927643 1.05676573-1.32095773 27.74010539 12.94538297 59.44308395 31.96716942 31.96716942 18.75759559 69.21816861 40.42129749 82.95612529 48.61123356l25.09819108 14.26633956.264192 103.56306148c.264192 73.7094235-.52838286 103.56306147-2.64191545 103.56306261-1.58514859 0-10.56765952-5.01963776-20.07855217-11.36023438zm0-61.29242453c0-11.09604238-.79257486-12.15280811-11.09604239-18.2292116-6.34059549-3.43448917-33.28812715-19.02178645-59.97146681-34.34489287s-48.87542443-28.00429739-49.40380842-28.00429739-1.05676573 5.28382976-1.05676573 11.62442525v11.36023325l60.23565881 34.60908486c33.02393515 19.28597845 60.23565881 34.87327573 60.76404054 34.87327574.264192 0 .52838286-5.28382976.528384-11.88861724zm0-42.27063695c0-11.09604238-.79257486-12.15280811-11.09604239-18.22921273-6.34059549-3.43448917-33.28812715-19.02178645-59.97146681-34.34489287s-48.87542443-28.00429739-49.40380842-28.00429739-1.05676573 5.28382976-1.05676573 11.62442525v11.36023438l60.23565881 34.60908373c33.02393515 19.28597845 60.23565881 34.87327573 60.76404054 34.87327688.264192 0 .52838286-5.28382976.528384-11.88861725zm-1.84934059-54.42344619c-2.11353145-2.11353145-117.30101931-68.42559488-118.88616789-68.42559374-.52838286 0-.79257486 5.28382976-.79257487 11.62442525v11.36023324l60.23565881 34.60908487 59.97146681 34.60908488.79257373-10.83185152c.52838286-5.81221262 0-11.62442525-1.32095659-12.94538298z"></path><path d="M109.10798734 615.82725347c-3.69868117-7.39736121-10.56765952-20.34274418-15.58729841-28.26848938-7.92574407-13.47376583-49.66799929-84.80546589-61.2924234-105.41240206-7.13317035-12.15280811-6.34059549-15.85148928 6.34059548-37.77938205 24.56980821-42.00644608 41.21387122-70.27493433 45.96931812-78.99325326 7.13317035-12.41700011 49.66799929-86.12642361 81.37097671-141.34244466 14.53053155-24.56980821 40.68548835-70.27493433 58.12212622-101.18533803l32.23136143-56.27278563h229.05401685c159.30746539 0 230.37497458 1.05676573 232.75269689 2.90610631 1.84934059 1.58514859 10.56765952 15.58729728 19.55017045 31.17459456 8.71831893 15.58729728 18.75759559 33.02393515 22.45627563 38.83614777l6.34059548 10.83185152-8.9825098 14.26633955c-5.01963776 7.92574407-15.32310642 25.89076594-22.72046762 39.62872264s-13.73795669 25.62657394-14.2663407 25.89076594c-.264192.52838286-83.2203173.79257486-184.40565532.79257486l-183.6130816-.264192-9.5108938 14.53053155c-5.01963776 7.92574407-9.24670179 15.85148928-9.24670179 17.17244701 0 1.58514859-1.05676573 2.64191431-2.64191431 2.64191431-1.32095773 0-2.64191431 1.05676573-2.64191545 2.11353145 0 2.90610631-29.32525511 55.21601991-48.61123243 87.18319047-8.18993607 13.47376583-14.79472355 25.09819107-14.79472355 25.8907648 0 1.05676573-3.43448917 6.86897835-7.92574407 13.47376583-4.22706403 6.34059549-7.92574407 12.15280811-7.92574521 12.94538297 0 .52838286-2.90610631 5.54802062-6.07640349 11.09604238-3.43448917 5.28382976-9.24670179 15.05891442-12.94538296 21.6637019s-20.07855331 35.13746773-36.45842546 63.40595599-31.96716942 55.21601991-34.34489288 59.44308394c-2.64191431 4.4912549-8.18993607 14.26634069-12.94538182 21.92789276-4.4912549 7.66155321-8.18993607 14.53053155-8.18993608 15.32310642 0 2.37772345-19.28597845 30.11782883-20.87112704 30.11782884-.79257486 0-4.4912549-6.34059549-8.18993607-13.7379567z"></path><path d="M625.60233813 601.56091278c-15.85148928-10.56765952-31.17459456-21.13531904-33.81651-23.51304135-4.22706403-3.69868117-4.7554469-9.24670179-4.4912549-56.00859477.264192-39.89291463-.264192-52.3099136-3.17029832-54.95182905-1.84934059-1.84934059-21.13531904-13.73795669-43.0632118-26.4191488-21.6637019-12.68119097-41.74225408-25.09819107-44.11997753-27.21172252-4.22706403-3.43448917-4.7554469-9.51089379-4.75544689-50.72476502 0-25.62657394.52838286-47.29027584 1.58514858-48.08284956.79257486-.79257486 8.18993607 2.90610631 16.37987214 8.45412693s25.36238194 15.85148928 37.77938205 22.72046763c12.41700011 7.13317035 43.06321181 25.09819107 67.89721201 40.15710549l45.44093526 27.21172366-.52838286 103.29886948c-.52838286 66.31206229-1.84934059 103.56306147-3.43448918 103.82725347-1.32095773.264192-15.58729728-8.18993607-31.70297856-18.75759559z"></path></svg></div></div> <span class="domain text-slate-600 dark:text-slate-300 text-lg md:text-2xl">Quick<span class="text-emerald-400">Ref</span>.ME</span></a><div class="md:ml-auto flex flex-wrap items-center text-base justify-center"> <button id="mysearch-trigger" type="button" class="fadeIn inline-flex h-8 items-center bg-slate-200 dark:bg-gray-900 md:dark:bg-transparent md:bg-transparent rounded-full px-2 md:px-3 lg:px-6 py-2 text-slate-700 md:hover:opacity-80"><div class="md:text-xl text-slate-700 dark:text-slate-300 md:mr-2"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M942.14826666 878.7968l-200.56746667-229.92213333C795.37493333 583.8848 827.73333333 500.5312 827.73333333 409.6 827.73333333 202.27413333 659.59253333 34.13333333 452.26666666 34.13333333 244.87253333 34.13333333 76.79999999 202.27413333 76.79999999 409.6S244.87253333 785.06666667 452.26666666 785.06666667c77.14133333 0 148.82133333-23.3472 208.41813333-63.21493334l199.33866667 228.5568c19.72906667 22.7328 54.272 24.91733333 76.8 5.25653334C959.62453333 935.86773333 961.87733333 901.46133333 942.14826666 878.7968zM179.19999999 409.6c0-150.59626667 122.4704-273.06666667 273.06666667-273.06666667 150.59626667 0 273.06666667 122.4704 273.06666667 273.06666667s-122.4704 273.06666667-273.06666667 273.06666667C301.67039999 682.66666667 179.19999999 560.19626667 179.19999999 409.6z"></path></svg></div> <span class="hidden md:inline dark:text-slate-300">Search for cheatsheet</span> <span class="hidden md:inline dark:text-slate-300 md:ml-2 text-sm leading-5 py-0.5 px-1.5 border border-slate-400 rounded-md"><span class="font-sans">⌘</span> <span class="font-sans">K</span></span></button> <a href="https://github.com/Fechin/reference/blob/main/source/_posts/yaml.md" rel="external nofollow noreferrer" target="_blank"><img alt="GitHub Repo stars" style="height:26px;opacity:.8" src="YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference_files/reference.svg"></a> <a href="https://twitter.com/FechinLi" rel="external nofollow noreferrer" target="_blank"><button type="button" class="fadeIn inline-flex h-8 items-center rounded-full bg-[#4d9feb] text-slate-100 ml-1 lg:ml-4 px-2 md:px-3 py-2 md:hover:opacity-80"><div class="md:mr-2"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M283.02655555 307.55600001c140.717 72.074 260.839 66.925 260.839 66.92499999s-44.617-157.87599999 94.384-228.234c138.998-70.359 236.816 48.048 236.816 48.048s24.025-6.863 42.901-13.728 44.617-18.87599999 44.61700001-18.876l-42.90100001 77.222 66.92500001-6.863s-8.579 12.014-34.31900001 36.038c-25.741 24.025-37.754 37.754-37.754 37.754s10.297 190.483-90.95 338.062c-99.53 147.58000001-229.952 235.099-417.002 253.973-187.05 18.87599999-310.606-58.347-310.606-58.347s82.37-5.149 133.852-24.025c51.483-20.592 126.99-73.79 126.99-73.79s-106.397-32.605-145.866-70.35899999-48.048-60.062-48.048-60.06200001l106.397-1.716s-111.542-60.062-142.433-106.397c-30.89-46.333-36.038-92.666-36.038-92.666l80.656 32.605s-66.925-92.666-77.222-163.025c-10.297-72.074 12.014-109.826 12.014-109.826s36.038 65.21 176.752 137.283z"></path></svg></div> <span class="hidden md:inline text-sm">Follow Me</span></button></a> <button id="darkMode" class="fadeIn inline-flex items-center justify-center flex-shrink-0 h-8 w-8 rounded-full text-gray-900 ml-1 lg:ml-4 dark:text-gray-300 bg-gray-200 dark:bg-gray-900"> <i class="icon-light text-gray-600 dark:text-gray-300 dark:hover:text-white"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M512 31.40266667c14.19946667 0 26.935296 8.14830933 31.93787733 20.447232l29.40381867 72.50466133c12.713984 31.30436267-4.456448 66.21320533-38.33856 77.96599467A70.34197333 70.34197333 0 0 1 512 206.16533333c-36.19771733 0-65.536-27.11005867-65.536-60.555264 0-7.25265067 1.41994667-14.46161067 4.17245867-21.25550933l29.425664-72.50466133C485.04285867 39.550976 497.75684267 31.40266667 512 31.40266667zm0 961.19466666c-14.221312 0-26.95714133-8.14830933-31.93787733-20.447232l-29.425664-72.50466133a56.492032 56.492032 0 0 1-4.17245867-21.25550933C446.464 844.96657067 475.80228267 817.83466667 512 817.83466667c7.86432 0 15.64125867 1.31072 23.003136 3.84477866 33.882112 11.75278933 51.052544 46.661632 38.33856 77.98784l-29.40381867 72.482816c-5.00258133 12.29892267-17.73841067 20.447232-31.93787733 20.447232zm480.59733333-480.59733333c0 14.19946667-8.14830933 26.935296-20.447232 31.93787733l-72.50466133 29.40381867c-31.30436267 12.713984-66.21320533-4.456448-77.96599467-38.33856A70.34197333 70.34197333 0 0 1 817.83466667 512c0-36.19771733 27.11005867-65.536 60.555264-65.536 7.25265067 0 14.46161067 1.41994667 21.25550933 4.17245867l72.50466133 29.425664c12.29892267 4.980736 20.447232 17.69472 20.447232 31.93787733zM31.40266667 512c0-14.221312 8.14830933-26.95714133 20.447232-31.93787733l72.50466133-29.425664c6.77205333-2.752512 13.98101333-4.17245867 21.25550933-4.17245867C179.03342933 446.464 206.16533333 475.80228267 206.16533333 512c0 7.86432-1.31072 15.64125867-3.84477866 23.003136-11.75278933 33.882112-46.661632 51.052544-77.98784 38.33856l-72.482816-29.40381867C39.550976 538.935296 31.40266667 526.19946667 31.40266667 512zM172.15214933 172.17399467c10.04885333-10.04885333 24.81629867-13.28196267 37.04968534-8.126464l72.06775466 30.45239466c31.1296 13.172736 43.66882133 49.98212267 28.00571734 82.24768a70.34197333 70.34197333 0 0 1-13.54410667 19.00544c-25.58088533 25.58088533-65.49230933 27.15374933-89.12896 3.49525334a56.492032 56.492032 0 0 1-12.10231467-17.97870934L164.04753067 209.22368c-5.177344-12.23338667-1.94423467-27.000832 8.10461866-37.04968533zm679.673856 679.673856c-10.04885333 10.04885333-24.81629867 13.28196267-37.04968533 8.10461866l-72.04590933-30.45239466a56.492032 56.492032 0 0 1-18.00055467-12.08046934c-23.63665067-23.658496-22.06378667-63.56992 3.51709867-89.15080533a70.34197333 70.34197333 0 0 1 19.00544-13.54410667c32.26555733-15.663104 69.074944-3.12388267 82.24768 28.00571734l30.45239466 72.06775466c5.15549867 12.23338667 1.92238933 26.97898667-8.126464 37.04968534zm0-679.69570134c10.04885333 10.04885333 13.28196267 24.81629867 8.126464 37.04968534l-30.45239466 72.06775466c-13.172736 31.1296-49.98212267 43.66882133-82.24768 28.00571734a70.34197333 70.34197333 0 0 1-19.00544-13.54410667c-25.58088533-25.58088533-27.15374933-65.49230933-3.49525334-89.12896 5.111808-5.15549867 11.206656-9.240576 17.97870934-12.10231467l72.04590933-30.45239466c12.23338667-5.177344 27.000832-1.94423467 37.04968533 8.10461866zM172.15214933 851.82600533c-10.04885333-10.04885333-13.28196267-24.81629867-8.10461866-37.04968533l30.45239466-72.04590933c2.83989333-6.77205333 6.946816-12.86690133 12.08046934-18.00055467 23.658496-23.63665067 63.56992-22.06378667 89.15080533 3.51709867 5.57056 5.57056 10.15808 12.01493333 13.54410667 19.00544 15.663104 32.26555733 3.12388267 69.074944-28.00571734 82.24768l-72.06775466 30.45239466c-12.23338667 5.15549867-26.97898667 1.92238933-37.04968534-8.126464zM512 752.29866667c-132.7104 0-240.29866667-107.58826667-240.29866667-240.29866667s107.58826667-240.29866667 240.29866667-240.29866667 240.29866667 107.58826667 240.29866667 240.29866667-107.58826667 240.29866667-240.29866667 240.29866667z"></path></svg></i></button> <a href="https://facebook.com/sharer/sharer.php?u=https://quickref.me/yaml.html" rel="external nofollow noreferrer" target="_blank"><button type="button" class="fadeIn inline-flex h-8 w-8 justify-center items-center rounded-full bg-[#4a66ad] text-slate-100 ml-1 lg:ml-4 px-2 md:px-3 py-2 md:hover:opacity-80"> <span class="text-md"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M594.74346667 51.53066667c-28.95893333 0-56.30826667 3.2192-88.48533334 16.0896-65.9616 27.34826667-98.13653333 88.48533333-98.13653333 186.6208v94.91946666h-91.70026667v157.66186667h91.70026667v455.28853333h186.6208v-455.28853333h127.09546667l17.696-157.66186667h-144.7936v-70.7872c0-22.52266667 1.60853333-38.61013333 8.04266666-46.65706666 8.04266667-14.47786667 24.13226667-20.91413333 49.872-20.91413334h85.26613334v-157.66186666h-143.184z"></path></svg></span> <span class="hidden">Facebook</span></button></a> <a href="https://twitter.com/intent/tweet/?text=This%20is%20a%20quick%20reference%20cheat%20sheet%20for%20understanding%20and%20writing%20YAML%20format%20configuration%20files.%20&amp;url=https://quickref.me/yaml.html" rel="external nofollow noreferrer" target="_blank"><button type="button" class="fadeIn inline-flex h-8 w-8 justify-center items-center rounded-full bg-[#4d9feb] text-slate-100 ml-1 lg:ml-4 px-2 md:px-3 py-2 md:hover:opacity-80"> <span class="text-md"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M283.02655555 307.55600001c140.717 72.074 260.839 66.925 260.839 66.92499999s-44.617-157.87599999 94.384-228.234c138.998-70.359 236.816 48.048 236.816 48.048s24.025-6.863 42.901-13.728 44.617-18.87599999 44.61700001-18.876l-42.90100001 77.222 66.92500001-6.863s-8.579 12.014-34.31900001 36.038c-25.741 24.025-37.754 37.754-37.754 37.754s10.297 190.483-90.95 338.062c-99.53 147.58000001-229.952 235.099-417.002 253.973-187.05 18.87599999-310.606-58.347-310.606-58.347s82.37-5.149 133.852-24.025c51.483-20.592 126.99-73.79 126.99-73.79s-106.397-32.605-145.866-70.35899999-48.048-60.062-48.048-60.06200001l106.397-1.716s-111.542-60.062-142.433-106.397c-30.89-46.333-36.038-92.666-36.038-92.666l80.656 32.605s-66.925-92.666-77.222-163.025c-10.297-72.074 12.014-109.826 12.014-109.826s36.038 65.21 176.752 137.283z"></path></svg></span> <span class="hidden">Twitter</span></button></a></div></div></div><div data-pw-desk="leaderboard_atf" id="pwDeskLbAtf"></div><script type="text/javascript">window.ramp.que.push(function(){window.ramp.addTag("pwDeskLbAtf")})</script></header><div class="mx-auto flex flex-wrap md:py-5 flex-col md:flex-row items-center"><div class="flex flex-col w-full mx-auto text-center my-8"><div class="max-container w-full"><h1 class="text-5xl mb-4"> <span class="text-slate-700 dark:text-slate-300 font-light">YAML</span> <span class="text-slate-400 dark:text-slate-500 font-extralight hidden md:inline">cheatsheet</span></h1><div class="lg:w-3/5 mx-auto intro leading-relaxed text-slate-600"><p>This is a quick reference cheat sheet for understanding and writing YAML format configuration files.</p></div></div></div><div id="mdLayout" class="mdLayout w-full max-container"><div data-pw-desk="leaderboard_btf" id="pwDeskLbBtf1"></div><script type="text/javascript">window.ramp.que.push(function(){window.ramp.addTag("pwDeskLbBtf1")})</script> 
        <div class="h2-wrap">
<h2 id="getting-started"><a class="h-anchor" href="#getting-started">#</a>Getting Started</h2>
<div class="h3-wrap-list">
<div class="h3-wrap">
<h3 id="introduction"><a class="h-anchor" href="#introduction">#</a>Introduction</h3>
<div class="section">
<p><a target="_blank" rel="noopener external nofollow noreferrer" href="https://yaml.org/">YAML</a> is a data serialisation language designed to be directly writable and readable by humans</p>
<ul class="marker-round">
<li>YAML does not allow the use of tabs</li>
<li>Must be space between the element parts</li>
<li>YAML is CASE sensitive</li>
<li>End your YAML file with the <code>.yaml</code> or <code>.yml</code> extension</li>
<li>YAML is a superset of JSON</li>
<li>Ansible playbooks are YAML files</li>
</ul>
</div>
</div>
<div class="h3-wrap row-span-2">
<h3 id="scalar-types"><a class="h-anchor" href="#scalar-types">#</a>Scalar types</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">n1:</span> <span class="hljs-number">1</span>            <span class="hljs-comment"># integer          </span>
<span class="hljs-attr">n2:</span> <span class="hljs-number">1.234</span>        <span class="hljs-comment"># float      </span>

<span class="hljs-attr">s1:</span> <span class="hljs-string">'abc'</span>        <span class="hljs-comment"># string        </span>
<span class="hljs-attr">s2:</span> <span class="hljs-string">"abc"</span>        <span class="hljs-comment"># string           </span>
<span class="hljs-attr">s3:</span> <span class="hljs-string">abc</span>          <span class="hljs-comment"># string           </span>

<span class="hljs-attr">b:</span> <span class="hljs-literal">false</span>         <span class="hljs-comment"># boolean type </span>

<span class="hljs-attr">d:</span> <span class="hljs-number">2015-04-05</span>    <span class="hljs-comment"># date type</span>
</code></pre>
<h4 id="↓-equivalent-json"><a class="h-anchor" href="#↓-equivalent-json">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"n1"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">1</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"n2"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">1.234</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"s1"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"abc"</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"s2"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"abc"</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"s3"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"abc"</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"b"</span><span class="hljs-punctuation">:</span> <span class="hljs-literal"><span class="hljs-keyword">false</span></span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"d"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"2015-04-05"</span>
<span class="hljs-punctuation">}</span>
</code></pre>
<p>Use spaces to indent. There must be space between the element parts.</p>
</div>
</div>
<div class="h3-wrap">
<h3 id="variables"><a class="h-anchor" href="#variables">#</a>Variables</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">some_thing:</span> <span class="hljs-string">&amp;VAR_NAME</span> <span class="hljs-string">foobar</span>
<span class="hljs-attr">other_thing:</span> <span class="hljs-meta">*VAR_NAME</span>
</code></pre>
<h4 id="↓-equivalent-json-2"><a class="h-anchor" href="#↓-equivalent-json-2">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"some_thing"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"foobar"</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"other_thing"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"foobar"</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="comments"><a class="h-anchor" href="#comments">#</a>Comments</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-comment"># A single line comment example</span>

<span class="hljs-comment"># block level comment example</span>
<span class="hljs-comment"># comment line 1</span>
<span class="hljs-comment"># comment line 2</span>
<span class="hljs-comment"># comment line 3</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="multiline-strings"><a class="h-anchor" href="#multiline-strings">#</a>Multiline strings</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">description:</span> <span class="hljs-string">|
  hello
  world
</span></code></pre>
<h4 id="↓-equivalent-json-3"><a class="h-anchor" href="#↓-equivalent-json-3">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span><span class="hljs-attr">"description"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"hello\nworld\n"</span><span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap row-span-2">
<h3 id="inheritance"><a class="h-anchor" href="#inheritance">#</a>Inheritance</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">parent:</span> <span class="hljs-meta">&amp;defaults</span>
  <span class="hljs-attr">a:</span> <span class="hljs-number">2</span>
  <span class="hljs-attr">b:</span> <span class="hljs-number">3</span>

<span class="hljs-attr">child:</span>
  <span class="hljs-string">&lt;&lt;:</span> <span class="hljs-meta">*defaults</span>
  <span class="hljs-attr">b:</span> <span class="hljs-number">4</span>
</code></pre>
<h4 id="↓-equivalent-json-4"><a class="h-anchor" href="#↓-equivalent-json-4">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"parent"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"a"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">2</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"b"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">3</span>
  <span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"child"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"a"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">2</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"b"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">4</span>
  <span class="hljs-punctuation">}</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap row-span-2">
<h3 id="reference"><a class="h-anchor" href="#reference">#</a>Reference</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">values:</span> <span class="hljs-meta">&amp;ref</span>
  <span class="hljs-bullet">-</span> <span class="hljs-string">Will</span> <span class="hljs-string">be</span>
  <span class="hljs-bullet">-</span> <span class="hljs-string">reused</span> <span class="hljs-string">below</span>
  
<span class="hljs-attr">other_values:</span>
  <span class="hljs-attr">i_am_ref:</span> <span class="hljs-meta">*ref</span>
</code></pre>
<h4 id="↓-equivalent-json-5"><a class="h-anchor" href="#↓-equivalent-json-5">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"values"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span>
    <span class="hljs-string">"Will be"</span><span class="hljs-punctuation">,</span>
    <span class="hljs-string">"reused below"</span>
  <span class="hljs-punctuation">]</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"other_values"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"i_am_ref"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span>
      <span class="hljs-string">"Will be"</span><span class="hljs-punctuation">,</span>
      <span class="hljs-string">"reused below"</span>
    <span class="hljs-punctuation">]</span>
  <span class="hljs-punctuation">}</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="folded-strings"><a class="h-anchor" href="#folded-strings">#</a>Folded strings</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">description:</span> <span class="hljs-string">&gt;
  hello
  world
</span></code></pre>
<h4 id="↓-equivalent-json-6"><a class="h-anchor" href="#↓-equivalent-json-6">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span><span class="hljs-attr">"description"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"hello world\n"</span><span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="two-documents"><a class="h-anchor" href="#two-documents">#</a>Two Documents</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-meta">---</span>
<span class="hljs-attr">document:</span> <span class="hljs-string">this</span> <span class="hljs-string">is</span> <span class="hljs-string">doc</span> <span class="hljs-number">1</span>
<span class="hljs-meta">---</span>
<span class="hljs-attr">document:</span> <span class="hljs-string">this</span> <span class="hljs-string">is</span> <span class="hljs-string">doc</span> <span class="hljs-number">2</span>
</code></pre>
<p>YAML uses <code>---</code> to separate directives from document content.</p>
</div>
</div>
</div>
</div>
<div class="h2-wrap">
<h2 id="yaml-collections"><a class="h-anchor" href="#yaml-collections">#</a>YAML Collections</h2>
<div class="h3-wrap-list">
<div class="h3-wrap">
<h3 id="sequence"><a class="h-anchor" href="#sequence">#</a>Sequence</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-bullet">-</span> <span class="hljs-string">Mark</span> <span class="hljs-string">McGwire</span>
<span class="hljs-bullet">-</span> <span class="hljs-string">Sammy</span> <span class="hljs-string">Sosa</span>
<span class="hljs-bullet">-</span> <span class="hljs-string">Ken</span> <span class="hljs-string">Griffey</span>
</code></pre>
<h4 id="↓-equivalent-json-7"><a class="h-anchor" href="#↓-equivalent-json-7">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">[</span>
  <span class="hljs-string">"Mark McGwire"</span><span class="hljs-punctuation">,</span>
  <span class="hljs-string">"Sammy Sosa"</span><span class="hljs-punctuation">,</span>
  <span class="hljs-string">"Ken Griffey"</span>
<span class="hljs-punctuation">]</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="mapping"><a class="h-anchor" href="#mapping">#</a>Mapping</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">hr:</span>  <span class="hljs-number">65</span>       <span class="hljs-comment"># Home runs</span>
<span class="hljs-attr">avg:</span> <span class="hljs-number">0.278</span>    <span class="hljs-comment"># Batting average</span>
<span class="hljs-attr">rbi:</span> <span class="hljs-number">147</span>      <span class="hljs-comment"># Runs Batted In</span>
</code></pre>
<h4 id="↓-equivalent-json-8"><a class="h-anchor" href="#↓-equivalent-json-8">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"hr"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">65</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"avg"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">0.278</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"rbi"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">147</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="mapping-to-sequences"><a class="h-anchor" href="#mapping-to-sequences">#</a>Mapping to Sequences</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">attributes:</span>
  <span class="hljs-bullet">-</span> <span class="hljs-string">a1</span>
  <span class="hljs-bullet">-</span> <span class="hljs-string">a2</span>
<span class="hljs-attr">methods:</span> [<span class="hljs-string">getter</span>, <span class="hljs-string">setter</span>]
</code></pre>
<h4 id="↓-equivalent-json-9"><a class="h-anchor" href="#↓-equivalent-json-9">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"attributes"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span><span class="hljs-string">"a1"</span><span class="hljs-punctuation">,</span> <span class="hljs-string">"a2"</span><span class="hljs-punctuation">]</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"methods"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span><span class="hljs-string">"getter"</span><span class="hljs-punctuation">,</span> <span class="hljs-string">"setter"</span><span class="hljs-punctuation">]</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="sequence-of-mappings"><a class="h-anchor" href="#sequence-of-mappings">#</a>Sequence of Mappings</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">children:</span>
  <span class="hljs-bullet">-</span> <span class="hljs-attr">name:</span> <span class="hljs-string">Jimmy</span> <span class="hljs-string">Smith</span>
    <span class="hljs-attr">age:</span> <span class="hljs-number">15</span>
  <span class="hljs-bullet">-</span> <span class="hljs-attr">name:</span> <span class="hljs-string">Jimmy</span> <span class="hljs-string">Smith</span>
    <span class="hljs-attr">age:</span> <span class="hljs-number">15</span>
  <span class="hljs-bullet">-</span>
    <span class="hljs-attr">name:</span> <span class="hljs-string">Sammy</span> <span class="hljs-string">Sosa</span>
    <span class="hljs-attr">age:</span> <span class="hljs-number">12</span>
</code></pre>
<h4 id="↓-equivalent-json-10"><a class="h-anchor" href="#↓-equivalent-json-10">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"children"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span>
    <span class="hljs-punctuation">{</span><span class="hljs-attr">"name"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"Jimmy Smith"</span><span class="hljs-punctuation">,</span> <span class="hljs-attr">"age"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">15</span><span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
    <span class="hljs-punctuation">{</span><span class="hljs-attr">"name"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"Jimmy Smith"</span><span class="hljs-punctuation">,</span> <span class="hljs-attr">"age"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">15</span><span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
    <span class="hljs-punctuation">{</span><span class="hljs-attr">"name"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"Sammy Sosa"</span><span class="hljs-punctuation">,</span> <span class="hljs-attr">"age"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">12</span><span class="hljs-punctuation">}</span>
  <span class="hljs-punctuation">]</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="sequence-of-sequences"><a class="h-anchor" href="#sequence-of-sequences">#</a>Sequence of Sequences</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">my_sequences:</span>
  <span class="hljs-bullet">-</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>]
  <span class="hljs-bullet">-</span> [<span class="hljs-number">4</span>, <span class="hljs-number">5</span>, <span class="hljs-number">6</span>]
  <span class="hljs-bullet">-</span>  
    <span class="hljs-bullet">-</span> <span class="hljs-number">7</span>
    <span class="hljs-bullet">-</span> <span class="hljs-number">8</span>
    <span class="hljs-bullet">-</span> <span class="hljs-number">9</span>
    <span class="hljs-bullet">-</span> <span class="hljs-number">0</span> 
</code></pre>
<h4 id="↓-equivalent-json-11"><a class="h-anchor" href="#↓-equivalent-json-11">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"my_sequences"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span>
    <span class="hljs-punctuation">[</span><span class="hljs-number">1</span><span class="hljs-punctuation">,</span> <span class="hljs-number">2</span><span class="hljs-punctuation">,</span> <span class="hljs-number">3</span><span class="hljs-punctuation">]</span><span class="hljs-punctuation">,</span>
    <span class="hljs-punctuation">[</span><span class="hljs-number">4</span><span class="hljs-punctuation">,</span> <span class="hljs-number">5</span><span class="hljs-punctuation">,</span> <span class="hljs-number">6</span><span class="hljs-punctuation">]</span><span class="hljs-punctuation">,</span>
    <span class="hljs-punctuation">[</span><span class="hljs-number">7</span><span class="hljs-punctuation">,</span> <span class="hljs-number">8</span><span class="hljs-punctuation">,</span> <span class="hljs-number">9</span><span class="hljs-punctuation">,</span> <span class="hljs-number">0</span><span class="hljs-punctuation">]</span>
  <span class="hljs-punctuation">]</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="mapping-of-mappings"><a class="h-anchor" href="#mapping-of-mappings">#</a>Mapping of Mappings</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">Mark McGwire:</span> {<span class="hljs-attr">hr:</span> <span class="hljs-number">65</span>, <span class="hljs-attr">avg:</span> <span class="hljs-number">0.278</span>}
<span class="hljs-attr">Sammy Sosa:</span> {
    <span class="hljs-attr">hr:</span> <span class="hljs-number">63</span>,
    <span class="hljs-attr">avg:</span> <span class="hljs-number">0.288</span>
  }
</code></pre>
<h4 id="↓-equivalent-json-12"><a class="h-anchor" href="#↓-equivalent-json-12">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"Mark McGwire"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"hr"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">65</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"avg"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">0.278</span>
  <span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"Sammy Sosa"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"hr"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">63</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"avg"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">0.288</span>
  <span class="hljs-punctuation">}</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="nested-collections"><a class="h-anchor" href="#nested-collections">#</a>Nested Collections</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">Jack:</span>
  <span class="hljs-attr">id:</span> <span class="hljs-number">1</span>
  <span class="hljs-attr">name:</span> <span class="hljs-string">Franc</span>
  <span class="hljs-attr">salary:</span> <span class="hljs-number">25000</span>
  <span class="hljs-attr">hobby:</span>
    <span class="hljs-bullet">-</span> <span class="hljs-string">a</span>
    <span class="hljs-bullet">-</span> <span class="hljs-string">b</span>
  <span class="hljs-attr">location:</span> {<span class="hljs-attr">country:</span> <span class="hljs-string">"A"</span>, <span class="hljs-attr">city:</span> <span class="hljs-string">"A-A"</span>}
</code></pre>
<h4 id="↓-equivalent-json-13"><a class="h-anchor" href="#↓-equivalent-json-13">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"Jack"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
    <span class="hljs-attr">"id"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">1</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"name"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"Franc"</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"salary"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">25000</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"hobby"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span><span class="hljs-string">"a"</span><span class="hljs-punctuation">,</span> <span class="hljs-string">"b"</span><span class="hljs-punctuation">]</span><span class="hljs-punctuation">,</span>
    <span class="hljs-attr">"location"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span>
        <span class="hljs-attr">"country"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"A"</span><span class="hljs-punctuation">,</span> <span class="hljs-attr">"city"</span><span class="hljs-punctuation">:</span> <span class="hljs-string">"A-A"</span>
    <span class="hljs-punctuation">}</span>
  <span class="hljs-punctuation">}</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
<div class="h3-wrap">
<h3 id="unordered-sets"><a class="h-anchor" href="#unordered-sets">#</a>Unordered Sets</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">set1:</span> <span class="hljs-type">!!set</span>
  <span class="hljs-string">?</span> <span class="hljs-string">one</span>
  <span class="hljs-string">?</span> <span class="hljs-string">two</span>
<span class="hljs-attr">set2:</span> <span class="hljs-type">!!set</span> {<span class="hljs-string">'one'</span>, <span class="hljs-string">"two"</span>}
</code></pre>
<h4 id="↓-equivalent-json-14"><a class="h-anchor" href="#↓-equivalent-json-14">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"set1"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span><span class="hljs-attr">"one"</span><span class="hljs-punctuation">:</span> <span class="hljs-literal"><span class="hljs-keyword">null</span></span><span class="hljs-punctuation">,</span> <span class="hljs-attr">"two"</span><span class="hljs-punctuation">:</span> <span class="hljs-literal"><span class="hljs-keyword">null</span></span><span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
  <span class="hljs-attr">"set2"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">{</span><span class="hljs-attr">"one"</span><span class="hljs-punctuation">:</span> <span class="hljs-literal"><span class="hljs-keyword">null</span></span><span class="hljs-punctuation">,</span> <span class="hljs-attr">"two"</span><span class="hljs-punctuation">:</span> <span class="hljs-literal"><span class="hljs-keyword">null</span></span><span class="hljs-punctuation">}</span>
<span class="hljs-punctuation">}</span>
</code></pre>
<p>Sets are represented as a Mapping where each key is associated with a null value</p>
</div>
</div>
<div class="h3-wrap">
<h3 id="ordered-mappings"><a class="h-anchor" href="#ordered-mappings">#</a>Ordered Mappings</h3>
<div class="section">
<pre><code class="hljs language-yaml"><span class="hljs-attr">ordered:</span> <span class="hljs-type">!!omap</span>
<span class="hljs-bullet">-</span> <span class="hljs-attr">Mark McGwire:</span> <span class="hljs-number">65</span>
<span class="hljs-bullet">-</span> <span class="hljs-attr">Sammy Sosa:</span> <span class="hljs-number">63</span>
<span class="hljs-bullet">-</span> <span class="hljs-attr">Ken Griffy:</span> <span class="hljs-number">58</span>
</code></pre>
<h4 id="↓-equivalent-json-15"><a class="h-anchor" href="#↓-equivalent-json-15">#</a>↓ Equivalent JSON</h4>
<pre><code class="hljs wrap language-json"><span class="hljs-punctuation">{</span>
  <span class="hljs-attr">"ordered"</span><span class="hljs-punctuation">:</span> <span class="hljs-punctuation">[</span>
     <span class="hljs-punctuation">{</span><span class="hljs-attr">"Mark McGwire"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">65</span><span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
     <span class="hljs-punctuation">{</span><span class="hljs-attr">"Sammy Sosa"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">63</span><span class="hljs-punctuation">}</span><span class="hljs-punctuation">,</span>
     <span class="hljs-punctuation">{</span><span class="hljs-attr">"Ken Griffy"</span><span class="hljs-punctuation">:</span> <span class="hljs-number">58</span><span class="hljs-punctuation">}</span>
  <span class="hljs-punctuation">]</span>
<span class="hljs-punctuation">}</span>
</code></pre>
</div>
</div>
</div>
</div>
<div class="h2-wrap">
<h2 id="yaml-reference"><a class="h-anchor" href="#yaml-reference">#</a>YAML Reference</h2>
<div class="h3-wrap-list">
<div class="h3-wrap">
<h3 id="terms"><a class="h-anchor" href="#terms">#</a>Terms</h3>
<div class="section">
<ul class="marker-round">
<li>Sequences aka arrays or lists</li>
<li>Scalars aka strings or numbers</li>
<li>Mappings aka hashes or dictionaries</li>
</ul>
<p>Based on the YAML.org <a target="_blank" rel="noopener external nofollow noreferrer" href="https://yaml.org/refcard.html">refcard</a>.</p>
</div>
</div>
<div class="h3-wrap">
<h3 id="document-indicators"><a class="h-anchor" href="#document-indicators">#</a>Document indicators</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>%</code></td>
<td>Directive indicator</td>
</tr>
<tr>
<td><code>---</code></td>
<td>Document header</td>
</tr>
<tr>
<td><code>...</code></td>
<td>Document terminator</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap row-span-2">
<h3 id="collection-indicators"><a class="h-anchor" href="#collection-indicators">#</a>Collection indicators</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>?</code></td>
<td>Key indicator</td>
</tr>
<tr>
<td><code>:</code></td>
<td>Value indicator</td>
</tr>
<tr>
<td><code>-</code></td>
<td>Nested series entry indicator</td>
</tr>
<tr>
<td><code>,</code></td>
<td>Separate in-line branch entries</td>
</tr>
<tr>
<td><code>[]</code></td>
<td>Surround in-line series branch</td>
</tr>
<tr>
<td><code>{}</code></td>
<td>Surround in-line keyed branch</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap">
<h3 id="alias-indicators"><a class="h-anchor" href="#alias-indicators">#</a>Alias indicators</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>&amp;</code></td>
<td>Anchor property</td>
</tr>
<tr>
<td><code>*</code></td>
<td>Alias indicator</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap">
<h3 id="special-keys"><a class="h-anchor" href="#special-keys">#</a>Special keys</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>=</code></td>
<td>Default "value" mapping key</td>
</tr>
<tr>
<td><code>&lt;&lt;</code></td>
<td>Merge keys from another mapping</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap">
<h3 id="scalar-indicators"><a class="h-anchor" href="#scalar-indicators">#</a>Scalar indicators</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>''</code></td>
<td>Surround in-line unescaped scalar</td>
</tr>
<tr>
<td><code>"</code></td>
<td>Surround in-line escaped scalar</td>
</tr>
<tr>
<td><code>|</code></td>
<td>Block scalar indicator</td>
</tr>
<tr>
<td><code>&gt;</code></td>
<td>Folded scalar indicator</td>
</tr>
<tr>
<td><code>-</code></td>
<td>Strip chomp modifier (<code>|-</code> or <code>&gt;-</code>)</td>
</tr>
<tr>
<td><code>+</code></td>
<td>Keep chomp modifier (<code>|+</code> or <code>&gt;+</code>)</td>
</tr>
<tr>
<td><code>1-9</code></td>
<td>Explicit indentation modifier (<code>|1</code> or <code>&gt;2</code>). <br> Modifiers can be combined (<code>|2-</code>, <code>&gt;+1</code>)</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap col-span-2">
<h3 id="tag-property-usually-unspecified"><a class="h-anchor" href="#tag-property-usually-unspecified">#</a>Tag Property (usually unspecified)</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>none</code></td>
<td>Unspecified tag (automatically resolved by application)</td>
</tr>
<tr>
<td><code>!</code></td>
<td>Non-specific tag (by default, <code>!!map</code>/<code>!!seq</code>/<code>!!str</code>)</td>
</tr>
<tr>
<td><code>!foo</code></td>
<td>Primary (by convention, means a local <code>!foo</code> tag)</td>
</tr>
<tr>
<td><code>!!foo</code></td>
<td>Secondary (by convention, means <code>tag:yaml.org,2002:foo</code>)</td>
</tr>
<tr>
<td><code>!h!foo</code></td>
<td>Requires <code>%TAG !h! &lt;prefix&gt;</code> (and then means <code>&lt;prefix&gt;foo</code>)</td>
</tr>
<tr>
<td><code>!&lt;foo&gt;</code></td>
<td>Verbatim tag (always means <code>foo</code>)</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap">
<h3 id="misc-indicators"><a class="h-anchor" href="#misc-indicators">#</a>Misc indicators</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>#</code></td>
<td>Throwaway comment indicator</td>
</tr>
<tr>
<td><code>`@</code></td>
<td>Both reserved for future use</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap row-span-2">
<h3 id="core-types-default-automatic-tags"><a class="h-anchor" href="#core-types-default-automatic-tags">#</a>Core types (default automatic tags)</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>!!map</code></td>
<td><code>{Hash table, dictionary, mapping}</code></td>
</tr>
<tr>
<td><code>!!seq</code></td>
<td><code>{List, array, tuple, vector, sequence}</code></td>
</tr>
<tr>
<td><code>!!str</code></td>
<td>Unicode string</td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap row-span-3">
<h3 id="escape-codes"><a class="h-anchor" href="#escape-codes">#</a>Escape Codes</h3>
<div class="section">
<h4 id="numeric"><a class="h-anchor" href="#numeric">#</a>Numeric</h4>
<ul class="cols-2 marker-none">
<li><code>\x12</code> (8-bit)</li>
<li><code>\u1234</code> (16-bit)</li>
<li><code>\U00102030</code> (32-bit)</li>
</ul>
<h4 id="protective"><a class="h-anchor" href="#protective">#</a>Protective</h4>
<ul class="cols-3 marker-none">
<li><code>\\</code> (\)</li>
<li><code>\"</code> (")</li>
<li><code>\ </code> ( )</li>
<li><code>\&lt;TAB&gt;</code> (TAB)</li>
</ul>
<h4 id="c"><a class="h-anchor" href="#c">#</a>C</h4>
<ul class="cols-3 marker-none">
<li><code>\0</code> (NUL)</li>
<li><code>\a</code> (BEL)</li>
<li><code>\b</code> (BS)</li>
<li><code>\f</code> (FF)</li>
<li><code>\n</code> (LF)</li>
<li><code>\r</code> (CR)</li>
<li><code>\t</code> (TAB)</li>
<li><code>\v</code> (VTAB)</li>
</ul>
<h4 id="additional"><a class="h-anchor" href="#additional">#</a>Additional</h4>
<ul class="cols-3 marker-none">
<li><code>\e</code> (ESC)</li>
<li><code>\_</code> (NBSP)</li>
<li><code>\N</code> (NEL)</li>
<li><code>\L</code> (LS)</li>
<li><code>\P</code> (PS)</li>
</ul>
</div>
</div>
<div class="h3-wrap">
<h3 id="more-types"><a class="h-anchor" href="#more-types">#</a>More types</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>!!set</code></td>
<td><code>{cherries, plums, apples}</code></td>
</tr>
<tr>
<td><code>!!omap</code></td>
<td><code>[one: 1, two: 2]</code></td>
</tr>
</tbody>
</table>
</div>
</div>
<div class="h3-wrap col-span-2">
<h3 id="language-independent-scalar-types"><a class="h-anchor" href="#language-independent-scalar-types">#</a>Language Independent Scalar Types</h3>
<div class="section">
<table>
<thead>
<tr>
<th></th>
<th></th>
</tr>
</thead>
<tbody>
<tr>
<td><code>{~, null}</code></td>
<td>Null (no value).</td>
</tr>
<tr>
<td><code>[1234, 0x4D2, 02333]</code></td>
<td>[Decimal int, Hexadecimal int, Octal int]</td>
</tr>
<tr>
<td><code>[1_230.15, 12.3015e+02]</code></td>
<td>[Fixed float, Exponential float]</td>
</tr>
<tr>
<td><code>[.inf, -.Inf, .NAN]</code></td>
<td>[Infinity (float), Negative, Not a number]</td>
</tr>
<tr>
<td><code>{Y, true, Yes, ON}</code></td>
<td>Boolean true</td>
</tr>
<tr>
<td><code>{n, FALSE, No, off}</code></td>
<td>Boolean false</td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
<div class="h2-wrap">
<h2 id="also-see"><a class="h-anchor" href="#also-see">#</a>Also see</h2>
<div class="h3-wrap-list">
<ul>
<li><a target="_blank" rel="noopener external nofollow noreferrer" href="https://yaml.org/refcard.html">YAML Reference Card</a> <em>(yaml.org)</em></li>
<li><a target="_blank" rel="noopener external nofollow noreferrer" href="https://learnxinyminutes.com/docs/yaml/">Learn X in Y minutes</a> <em>(learnxinyminutes.com)</em></li>
<li><a target="_blank" rel="noopener external nofollow noreferrer" href="http://www.yamllint.com/">YAML lint online</a> <em>(yamllint.com)</em></li>
</ul>
</div>
</div>

        <div data-pw-desk="med_rect_btf" id="pwDeskMedRectBtf3"></div><script type="text/javascript">window.ramp.que.push(function(){window.ramp.addTag("pwDeskMedRectBtf3")})</script></div></div><script>!function(e,n,t,r){var o=n.createElement(t);o.async=1,o.src="https://a.ad.gt/api/v1/u/matches/514?url="+encodeURIComponent(e.location.href)+"&ref="+encodeURIComponent(n.referrer);var a=n.getElementsByTagName(t)[0];a.parentNode.insertBefore(o,a)}(window,document,"script")</script><div id="mysearch" class="z-50 fixed inset-0 flex justify-center bg-slate-600/80 dark:bg-slate-900/90 items-start text-sm z-50 overflow-hidden lg:pt-16 lg:pb-20 hidden"><div id="mysearch-box" class="lg:max-w-screen-lg w-full flex flex-col justify-between bg-white dark:bg-slate-700 shadow-3xl dark:shadow-3xl lg:rounded-lg lg:max-h-832 min-h-320 h-full"><div class="flex items-center h-16 flex-none border-b border-slate-200 dark:border-slate-700"><div class="w-full h-full"><form class="flex items-center w-full h-full outline-none rounded-tl-lg"><label for="mysearch-input" id="mysearch-label" class="h-full w-14 mt-1 ml-1 px-4 flex items-center justify-center transition-colors duration-200 ease-in-out text-emerald-200"><div class="text-2xl text-emerald-500"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M942.14826666 878.7968l-200.56746667-229.92213333C795.37493333 583.8848 827.73333333 500.5312 827.73333333 409.6 827.73333333 202.27413333 659.59253333 34.13333333 452.26666666 34.13333333 244.87253333 34.13333333 76.79999999 202.27413333 76.79999999 409.6S244.87253333 785.06666667 452.26666666 785.06666667c77.14133333 0 148.82133333-23.3472 208.41813333-63.21493334l199.33866667 228.5568c19.72906667 22.7328 54.272 24.91733333 76.8 5.25653334C959.62453333 935.86773333 961.87733333 901.46133333 942.14826666 878.7968zM179.19999999 409.6c0-150.59626667 122.4704-273.06666667 273.06666667-273.06666667 150.59626667 0 273.06666667 122.4704 273.06666667 273.06666667s-122.4704 273.06666667-273.06666667 273.06666667C301.67039999 682.66666667 179.19999999 560.19626667 179.19999999 409.6z"></path></svg></div></label><div class="relative flex-1"> <input class="flex-1 font-light h-full bg-transparent focus:text-slate-900 text-slate-500 dark:text-slate-300 placeholder-slate-400 placeholder-opacity-80 shadow-none outline-none truncate text-lg sm:text-2xl caret-color-emerald-400 leading-normalized w-full appearance-none rounded-none transition-colors duration-200 ease-in-out" id="mysearch-input" autocomplete="off" autocorrect="off" autocapitalize="none" spellcheck="false" placeholder="Search for cheatsheet" maxlength="128" type="text" enterkeyhint="go"></div> <button id="mysearch-clear" type="reset" class="items-center justify-center h-full w-14 px-4 text-slate-600 dark:text-slate-300 hover:text-slate-800 dark:hover:text-slate-100 opacity-75 fill-current cursor-pointer transition-fast-out flex"><i class="icon icon-close text-xs font-bold"></i></button></form></div><div class="w-px h-8 bg-slate-100 dark:bg-slate-400/20 flex-none"></div> <button class="cancel mr-1 px-4 h-full text-slate-500 dark:text-slate-300 hover:text-slate-800 dark:hover:text-slate-300"> Cancel</button></div><div class="flex flex-grow overflow-hidden lg:rounded-br-lg"><div class="relative w-full flex-none overflow-y-auto lg:w-1/2"><ul id="mysearch-list"></ul></div><div class="preview-panel shadow-inner bg-slate-100 dark:bg-slate-800 lg:block w-1/2 flex-none overflow-y-auto"></div></div></div></div><footer class="text-slate-700 dark:text-slate-300 bg-slate-200 dark:bg-slate-800 md:mt-14"><div class="max-container mb-8 md:py-10 mx-auto flex md:items-center lg:items-start md:flex-row flex-col"><div class="grid grid-cols-1 md:grid-cols-2 md:flex-grow md:flex -mb-10 md:mt-0 mt-10"><div class="md:w-1/2 md:pr-4"><h2 class="my-6 text-xl text-slate-700 dark:text-slate-300">Related <span class="text-slate-400">Cheatsheet</span></h2><section class="w-full grid grid-cols-2 gap-2 md:gap-4"><a href="https://quickref.me/es6" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">ES6 <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a><a href="https://quickref.me/express" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">Express <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a><a href="https://quickref.me/json" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">JSON <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a><a href="https://quickref.me/kubernetes" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">Kubernetes <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a></section></div><div class="md:w-1/2 md:pl-4"><h2 class="my-6 text-xl text-slate-700 dark:text-slate-300">Recent <span class="text-slate-400">Cheatsheet</span></h2><section class="w-full grid grid-cols-2 gap-2 md:gap-4"><a href="https://quickref.me/remote-work-revolution" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">Remote Work Revolution <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a><a href="https://quickref.me/homebrew" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">Homebrew <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a><a href="https://quickref.me/pytorch" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">PyTorch <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a><a href="https://quickref.me/taskset" class="group flex items-center p-3 bg-slate-50 rounded-lg hover:shadow dark:bg-slate-900 hover:bg-emerald-500 fadeIn"><div class="ml-4 truncate hover:text-clip overflow-hidden"><p class="mb-1 text-sm font-medium text-slate-900 dark:text-slate-300 group-hover:text-white">Taskset <span class="text-slate-400 group-hover:text-white">Cheatsheet</span></p><p class="text-sm font-normal text-slate-400 group-hover:text-white">Quick Reference</p></div></a></section></div></div><div class="hidden md:block flex-shrink-0 mx-auto block mt-8 md:mx-8 max-w-xs"><a href="https://quickref.me/" class="flex font-medium items-center justify-center md:justify-start text-slate-800 dark:text-slate-300"><div class="hidden md:flex justify-center w-10 h-10 md:w-12 md:h-12 text-white p-2 bg-emerald-500 rounded-full mr-3 text-2xl"><div class="self-center"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M303.55291933 951.35043811c-1.84934059-3.43448917-12.68119097-22.19208477-24.04142536-41.74225521l-20.07855218-35.4016586 5.01963776-9.51089265c2.90610631-5.01963776 13.20957383-23.24885049 22.9846585-40.15710664l17.70082986-31.17459456h366.69778034l6.86897834-11.09604238c3.43448917-6.34059549 13.73795669-23.77723335 22.72046763-39.10033977 8.71831893-15.32310642 22.19208477-38.30776491 29.85363797-51.51733873 7.66155321-12.94538297 16.37987214-28.00429739 19.02178646-33.02393629 2.90610631-5.28382976 14.00214869-24.30561621 24.56980821-42.27063694 10.56765952-18.22921273 29.85363797-51.51733987 43.06321181-73.97361551 12.94538297-22.45627563 35.93004146-62.08499826 51.25314787-87.71157333 15.05891442-25.89076594 28.53268025-49.93219015 29.85363797-53.63087132 3.43448917-8.98251093 8.45412693-8.18993607 12.94538184 2.11353259 2.11353145 4.4912549 8.71831893 16.90825501 14.79472355 26.94753166 6.34059549 10.30346752 20.60693618 35.13746773 32.23136143 55.48021077s25.62657394 44.38416953 30.91040369 53.63087133l9.77508466 16.64406414-6.07640462 9.77508466c-3.43448917 5.28382976-7.13317035 11.62442525-8.71831893 14.00214869-2.90610631 4.7554469-13.73795669 23.77723335-24.83399908 43.3274038-3.96287203 7.39736121-13.47376583 23.77723335-21.13531904 36.45842432-7.39736121 12.94538297-13.47376583 24.04142535-13.47376583 24.56980821 0 .79257486-3.43448917 6.34059549-7.39736121 12.41699898-4.22706403 6.07640462-9.51089379 15.32310642-12.15280811 20.34274531-2.37772345 5.01963776-6.86897835 12.94538297-9.77508465 17.17244587-2.64191431 4.4912549-5.81221262 10.03927666-6.60478749 12.68119096-1.05676573 2.37772345-2.64191431 4.4912549-3.69868117 4.49125604s-2.64191431 2.11353145-3.43448918 4.75544576c-1.05676573 2.37772345-5.28382976 10.56765952-9.77508466 17.70082987-4.22706403 7.39736121-10.56765952 17.96502073-13.47376582 23.77723335-3.17029831 5.81221262-10.83185038 19.28597845-17.17244587 29.58944597-6.34059549 10.56765952-11.62442525 20.07855331-11.62442525 21.13531904 0 .79257486-1.58514859 3.69868117-3.69868117 5.81221263-2.11353145 2.37772345-8.71831893 13.73795669-14.79472355 25.36238307s-18.22921273 33.81651001-26.94753053 49.66799815l-16.11568128 28.26848939H307.25159936l-3.69868003-5.81221263z"></path><path d="M523.88861725 694.82050674c-31.70297856-20.60693618-68.95397774-44.11997753-70.01074347-44.11997753-.79257486 0-10.03927666-5.81221262-20.60693618-13.20957383-10.83185038-7.13317035-22.72046763-14.53053155-26.68333966-16.11568128-3.69868117-1.84934059-6.86897835-3.96287203-6.86897835-5.01963776 0-.79257486-4.7554469-4.22706403-10.56765952-7.66155321l-10.30346752-5.81221262-.79257486-98.27923172c-.52838286-54.15925419 0-99.33599744.79257486-100.3927643 1.05676573-1.32095773 27.74010539 12.94538297 59.44308395 31.96716942 31.96716942 18.75759559 69.21816861 40.42129749 82.95612529 48.61123356l25.09819108 14.26633956.264192 103.56306148c.264192 73.7094235-.52838286 103.56306147-2.64191545 103.56306261-1.58514859 0-10.56765952-5.01963776-20.07855217-11.36023438zm0-61.29242453c0-11.09604238-.79257486-12.15280811-11.09604239-18.2292116-6.34059549-3.43448917-33.28812715-19.02178645-59.97146681-34.34489287s-48.87542443-28.00429739-49.40380842-28.00429739-1.05676573 5.28382976-1.05676573 11.62442525v11.36023325l60.23565881 34.60908486c33.02393515 19.28597845 60.23565881 34.87327573 60.76404054 34.87327574.264192 0 .52838286-5.28382976.528384-11.88861724zm0-42.27063695c0-11.09604238-.79257486-12.15280811-11.09604239-18.22921273-6.34059549-3.43448917-33.28812715-19.02178645-59.97146681-34.34489287s-48.87542443-28.00429739-49.40380842-28.00429739-1.05676573 5.28382976-1.05676573 11.62442525v11.36023438l60.23565881 34.60908373c33.02393515 19.28597845 60.23565881 34.87327573 60.76404054 34.87327688.264192 0 .52838286-5.28382976.528384-11.88861725zm-1.84934059-54.42344619c-2.11353145-2.11353145-117.30101931-68.42559488-118.88616789-68.42559374-.52838286 0-.79257486 5.28382976-.79257487 11.62442525v11.36023324l60.23565881 34.60908487 59.97146681 34.60908488.79257373-10.83185152c.52838286-5.81221262 0-11.62442525-1.32095659-12.94538298z"></path><path d="M109.10798734 615.82725347c-3.69868117-7.39736121-10.56765952-20.34274418-15.58729841-28.26848938-7.92574407-13.47376583-49.66799929-84.80546589-61.2924234-105.41240206-7.13317035-12.15280811-6.34059549-15.85148928 6.34059548-37.77938205 24.56980821-42.00644608 41.21387122-70.27493433 45.96931812-78.99325326 7.13317035-12.41700011 49.66799929-86.12642361 81.37097671-141.34244466 14.53053155-24.56980821 40.68548835-70.27493433 58.12212622-101.18533803l32.23136143-56.27278563h229.05401685c159.30746539 0 230.37497458 1.05676573 232.75269689 2.90610631 1.84934059 1.58514859 10.56765952 15.58729728 19.55017045 31.17459456 8.71831893 15.58729728 18.75759559 33.02393515 22.45627563 38.83614777l6.34059548 10.83185152-8.9825098 14.26633955c-5.01963776 7.92574407-15.32310642 25.89076594-22.72046762 39.62872264s-13.73795669 25.62657394-14.2663407 25.89076594c-.264192.52838286-83.2203173.79257486-184.40565532.79257486l-183.6130816-.264192-9.5108938 14.53053155c-5.01963776 7.92574407-9.24670179 15.85148928-9.24670179 17.17244701 0 1.58514859-1.05676573 2.64191431-2.64191431 2.64191431-1.32095773 0-2.64191431 1.05676573-2.64191545 2.11353145 0 2.90610631-29.32525511 55.21601991-48.61123243 87.18319047-8.18993607 13.47376583-14.79472355 25.09819107-14.79472355 25.8907648 0 1.05676573-3.43448917 6.86897835-7.92574407 13.47376583-4.22706403 6.34059549-7.92574407 12.15280811-7.92574521 12.94538297 0 .52838286-2.90610631 5.54802062-6.07640349 11.09604238-3.43448917 5.28382976-9.24670179 15.05891442-12.94538296 21.6637019s-20.07855331 35.13746773-36.45842546 63.40595599-31.96716942 55.21601991-34.34489288 59.44308394c-2.64191431 4.4912549-8.18993607 14.26634069-12.94538182 21.92789276-4.4912549 7.66155321-8.18993607 14.53053155-8.18993608 15.32310642 0 2.37772345-19.28597845 30.11782883-20.87112704 30.11782884-.79257486 0-4.4912549-6.34059549-8.18993607-13.7379567z"></path><path d="M625.60233813 601.56091278c-15.85148928-10.56765952-31.17459456-21.13531904-33.81651-23.51304135-4.22706403-3.69868117-4.7554469-9.24670179-4.4912549-56.00859477.264192-39.89291463-.264192-52.3099136-3.17029832-54.95182905-1.84934059-1.84934059-21.13531904-13.73795669-43.0632118-26.4191488-21.6637019-12.68119097-41.74225408-25.09819107-44.11997753-27.21172252-4.22706403-3.43448917-4.7554469-9.51089379-4.75544689-50.72476502 0-25.62657394.52838286-47.29027584 1.58514858-48.08284956.79257486-.79257486 8.18993607 2.90610631 16.37987214 8.45412693s25.36238194 15.85148928 37.77938205 22.72046763c12.41700011 7.13317035 43.06321181 25.09819107 67.89721201 40.15710549l45.44093526 27.21172366-.52838286 103.29886948c-.52838286 66.31206229-1.84934059 103.56306147-3.43448918 103.82725347-1.32095773.264192-15.58729728-8.18993607-31.70297856-18.75759559z"></path></svg></div></div> <span class="domain text-slate-600 dark:text-slate-300 text-lg md:text-2xl">Quick<span class="text-emerald-400">Ref</span>.ME</span></a><h4 class="mt-5 text-sm text-slate-500">Share quick reference and cheat sheet for developers.</h4><div class="share mt-4"> <a href="https://quickref.me/zh-CN/">中文版</a> <a href="https://quickref.me/notes/">#Notes</a></div><div class="share mt-8"><div class="inline-flex text-slate-500 sm:ml-auto sm:mt-0 mt-2 justify-center sm:justify-start"> <a class="mr-3 fadeIn hover:text-slate-700 dark:hover:text-slate-300" href="https://facebook.com/sharer/sharer.php?u=https://quickref.me/yaml.html" rel="external nofollow noreferrer" target="_blank"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M594.74346667 51.53066667c-28.95893333 0-56.30826667 3.2192-88.48533334 16.0896-65.9616 27.34826667-98.13653333 88.48533333-98.13653333 186.6208v94.91946666h-91.70026667v157.66186667h91.70026667v455.28853333h186.6208v-455.28853333h127.09546667l17.696-157.66186667h-144.7936v-70.7872c0-22.52266667 1.60853333-38.61013333 8.04266666-46.65706666 8.04266667-14.47786667 24.13226667-20.91413333 49.872-20.91413334h85.26613334v-157.66186666h-143.184z"></path></svg></a> <a class="mx-3 fadeIn hover:text-slate-700 dark:hover:text-slate-300" href="https://twitter.com/intent/tweet/?text=This%20is%20a%20quick%20reference%20cheat%20sheet%20for%20understanding%20and%20writing%20YAML%20format%20configuration%20files.%20&amp;url=https://quickref.me/yaml.html" rel="external nofollow noreferrer" target="_blank"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M283.02655555 307.55600001c140.717 72.074 260.839 66.925 260.839 66.92499999s-44.617-157.87599999 94.384-228.234c138.998-70.359 236.816 48.048 236.816 48.048s24.025-6.863 42.901-13.728 44.617-18.87599999 44.61700001-18.876l-42.90100001 77.222 66.92500001-6.863s-8.579 12.014-34.31900001 36.038c-25.741 24.025-37.754 37.754-37.754 37.754s10.297 190.483-90.95 338.062c-99.53 147.58000001-229.952 235.099-417.002 253.973-187.05 18.87599999-310.606-58.347-310.606-58.347s82.37-5.149 133.852-24.025c51.483-20.592 126.99-73.79 126.99-73.79s-106.397-32.605-145.866-70.35899999-48.048-60.062-48.048-60.06200001l106.397-1.716s-111.542-60.062-142.433-106.397c-30.89-46.333-36.038-92.666-36.038-92.666l80.656 32.605s-66.925-92.666-77.222-163.025c-10.297-72.074 12.014-109.826 12.014-109.826s36.038 65.21 176.752 137.283z"></path></svg></a> <a class="mx-3 fadeIn hover:text-slate-700 dark:hover:text-slate-300" href="https://reddit.com/submit/?url=https://quickref.me/yaml.html&amp;resubmit=true&amp;title=This%20is%20a%20quick%20reference%20cheat%20sheet%20for%20understanding%20and%20writing%20YAML%20format%20configuration%20files." rel="external nofollow noreferrer" target="_blank"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M830.73813333 279.88586667c29.1712 0 54.9152-24.02453333 54.9152-54.9152s-24.02453333-54.9152-54.9152-54.9152c-29.1712 0-54.9152 24.02453333-54.9152 54.9152 0 29.1712 24.02453333 54.9152 54.9152 54.9152zM518.416 741.504c-97.81333333 0-154.44693333-41.184-154.44693333-41.184-5.1488-3.4336-10.29653333-1.71626667-12.01386667 3.4336l-10.29653333 18.87573333c-1.71626667 5.1488-1.71626667 12.01386667 3.4336 15.4432 0 0 48.048 49.76746667 173.32266666 49.76746667s169.888-53.1968 169.888-53.1968c3.4336-3.4336 3.4336-10.29653333 1.71626667-13.728l-12.01386667-17.16266667c-3.4336-3.4336-8.5792-5.1488-13.728-1.71626666 0-1.71626667-48.048 39.46986667-145.8656 39.46986666zM341.66506667 609.3696c29.1712 0 54.9152-24.02453333 54.9152-54.9152s-24.02453333-54.9152-54.9152-54.9152c-29.1712 0-54.9152 24.02453333-54.9152 54.9152 1.71626667 30.8896 25.7408 54.9152 54.9152 54.9152zM667.71413333 609.3696c29.1712 0 54.9152-24.02453333 54.9152-54.9152s-24.02453333-54.9152-54.9152-54.9152-54.9152 24.02453333-54.9152 54.9152c0 30.8896 24.02453333 54.9152 54.9152 54.9152zM722.6272 216.39466667c-8.5792-3.4336-101.24693333-34.31893333-140.7168-6.86293334-41.184 29.1712-39.46986667 125.2704-36.0384 125.2704 90.9504 6.86293333 175.0368 34.31893333 238.53013333 77.2224 5.1488 3.4336 60.06186667-44.61653333 120.1248-34.31893333 60.06186667 10.29653333 101.24693333 66.9248 82.37013334 130.4192-18.87573333 61.77813333-77.2224 80.656-75.50613334 99.5296v15.4432c0 159.5936-181.9008 288.29653333-406.704 288.29653333s-406.704-128.70293333-406.704-288.29653333c0-8.5792 0-15.4432 1.71626667-24.02453333 0-1.71626667-41.184-24.02453333-56.62933333-61.77813334-15.4432-36.0384-8.5792-78.9376 6.86293333-104.67946666 25.7408-39.46986667 56.62933333-54.9152 99.5296-54.9152s89.2352 25.7408 90.9504 25.7408c68.6432-41.184 157.87626667-66.9248 253.97333333-68.6432 3.4336 0-6.86293333-116.6912 58.34666667-159.5936 66.9248-42.90133333 176.752 0 178.46933333 0v3.4336c17.16266667-37.7536 54.9152-63.49333333 97.81333334-63.49333334 60.06186667 0 108.11306667 49.76746667 108.11306666 109.82613334 0 60.06186667-48.048 109.82613333-108.11306666 109.82613333s-108.11306667-49.76746667-108.11306667-109.82613333c0-3.4336 0-6.86293333 1.71626667-8.5792z"></path></svg></a> <a class="mx-3 fadeIn hover:text-slate-700 dark:hover:text-slate-300" href="https://pinterest.com/pin/create/button/?url=https://quickref.me/yaml.html&amp;description=This%20is%20a%20quick%20reference%20cheat%20sheet%20for%20understanding%20and%20writing%20YAML%20format%20configuration%20files." rel="external nofollow noreferrer" target="_blank"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M977 512c0 256.875-208.125 465-465 465-48 0-94.125-7.3125-137.625-20.8125 18.9375-30.9375 47.25-81.5625 57.75-121.875 5.625-21.75 28.875-110.625 28.875-110.625 15.1875 28.875 59.4375 53.4375 106.5 53.4375 140.25 0 241.3125-129 241.3125-289.3125 0-153.5625-125.4375-268.5-286.6875-268.5-200.625 0-307.3125 134.625-307.3125 281.4375 0 68.25 36.375 153.1875 94.3125 180.1875 8.8125 4.125 13.5 2.25 15.5625-6.1875 1.5-6.375 9.375-38.0625 12.9375-52.6875 1.125-4.6875.5625-8.8125-3.1875-13.3125-18.9375-23.4375-34.3125-66.1875-34.3125-106.125 0-102.5625 77.625-201.75 210-201.75 114.1875 0 194.25 77.8125 194.25 189.1875 0 125.8125-63.5625 213-146.25 213-45.5625 0-79.875-37.6875-68.8125-84 13.125-55.3125 38.4375-114.9375 38.4375-154.875 0-35.625-19.125-65.4375-58.875-65.4375-46.6875 0-84.1875 48.1875-84.1875 112.875 0 41.25 13.875 69 13.875 69s-45.9375 194.625-54.375 231c-9.375 40.125-5.625 96.75-1.6875 133.5C169.625 877.4375 47 709.0625 47 512 47 255.125 255.125 47 512 47s465 208.125 465 465z"></path></svg></a> <a class="mx-3 fadeIn hover:text-slate-700 dark:hover:text-slate-300" href="https://www.linkedin.com/shareArticle?url=https://quickref.me/yaml.html&amp;title=YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference&amp;summary=This%20is%20a%20quick%20reference%20cheat%20sheet%20for%20understanding%20and%20writing%20YAML%20format%20configuration%20files." rel="external nofollow noreferrer" target="_blank"><svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" fill="currentColor" height="1em" width="1em" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""><path d="M387.20790124 931.03893333h183.53386665v-355.35146666c0-17.5712 1.952-37.0976 7.80906668-48.81173334 11.7152-35.1456 42.95573333-72.24106667 93.7184-72.24106665 66.38613333 0 93.7184 54.66773333 93.7184 132.76799999v341.68426666h183.53386667v-365.11466665c0-181.58293333-89.8144-265.53706667-210.86826667-265.53706668-97.62559999 0-158.14933333 58.576-181.58293333 97.6256h-3.90720001l-7.80906666-83.95626667h-160.10453333c1.952 54.66773333 3.9072 119.10186667 3.9072 197.20320001v421.73759999zM149.00310124 46.56213332c-58.576 0-97.62559999 41.00373333-95.67146668 97.62560001-1.952 52.7168 37.0976 95.67146668 95.67146668 95.67146668 60.52586667 0 99.5776-42.95573333 99.5776-95.67146668-3.9072-56.624-41.00373333-97.62559999-99.5776-97.62559999zM240.7705679 931.03893333v-616.98346666h-183.53386666v616.98346666h183.53386666z"></path></svg></a><a class="ml-3 fadeIn hover:text-slate-700 dark:hover:text-slate-300" href="https://social-plugins.line.me/lineit/share?url=https://quickref.me/yaml.html" rel="external nofollow noreferrer" target="_blank"><!--?xml version="1.0" standalone="no"?--><svg t="1672903354277" class="icon" viewBox="0 0 1107 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="11220" xlink="http://www.w3.org/1999/xlink" width="1em" height="1em"><path d="M551.3440625 32C264.509375 32 32 215.0290625 32 440.7875c0 209.7046875 200.7028125 382.425 459.1471875 405.9534375a31.60125001 31.60125001 0 0 1 21.105 13.7859375c11.4721875 18.8859375 3.320625 59.1271875-5.5875 104.2471875s39.5334375 21.7021875 50.25 16.4775c8.53125001-4.1390625 228.103125-127.91625001 358.820625-249.3009375 95.5903125-74.15625001 154.921875-177.20625001 154.921875-291.148125C1070.688125 215.0290625 838.16375001 32 551.3440625 32zM378.2290625 547.7721875a27.6984375 27.6984375 0 0 1-27.91875 27.44625H255.3659375c-16.760625 0-39.091875-5.791875-39.091875-32.9390625v-203.01562499a27.6825 27.6825 0 0 1 27.91875-27.44718751h5.5865625a27.6825 27.6825 0 0 1 27.91875 27.44625v175.5703125h72.59812499a27.6984375 27.6984375 0 0 1 27.93375001 27.44625v5.4928125zm78.264375-5.46093749a27.886875 27.886875 0 0 1-55.77468751 0V345.085625a27.886875 27.886875 0 0 1 55.77468751 0v197.22562499zm245.634375 0a30.8625 30.8625 0 0 1-27.91875 27.44624999 31.60125001 31.60125001 0 0 1-32.908125-15.7378125l-89.956875-126.16875v114.4284375a27.91875001 27.91875001 0 0 1-55.8215625 0V344.7396875a27.6665625 27.6665625 0 0 1 27.9028125-27.43125 35.315625 35.315625 0 0 1 31.6490625 20.0971875c8.655 12.7790625 91.27875001 127.9790625 91.27875 127.9790625V344.740625a27.9346875 27.9346875 0 0 1 55.8525 0v197.5396875zm167.5275-126.20062501a27.44624999 27.44624999 0 1 1 0 54.8925H797.05625001v43.8928125h72.59812499a27.44624999 27.44624999 0 1 1 0 54.8775H760.765625a24.8971875 24.8971875 0 0 1-25.1803125-24.676875V342.033125a24.8971875 24.8971875 0 0 1 25.18125-24.6928125h108.88875a27.44624999 27.44624999 0 1 1 0 54.8775H797.05625001v43.9078125h72.59812499z" fill="currentColor" p-id="11221" style="--darkreader-inline-fill: currentColor;" data-darkreader-inline-fill=""></path></svg></a></div></div></div></div><div class="max-container border-b border-slate-300 dark:border-slate-700"></div><div class="max-container flex flex-col sm:flex-row items-center"><p class="py-2 md:py-3 text-slate-500 text-sm text-center w-full"> © 2023 QuickRef.ME, All rights reserved.</p></div><script async="" src="YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference_files/ramp_core.js"></script></footer><div id="carbon_container"></div><script src="YAML%20Cheat%20Sheet%20&amp;%20Quick%20Reference_files/main.js"></script><script>
        // Get all pre > code elements
        const codeBlocks = document.querySelectorAll('pre > code');
        const initInnerHTML = '<svg height="1em" fill="currentColor" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M0 6.75C0 5.784.784 5 1.75 5h1.5a.75.75 0 010 1.5h-1.5a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-1.5a.75.75 0 011.5 0v1.5A1.75 1.75 0 019.25 16h-7.5A1.75 1.75 0 010 14.25v-7.5z"></path><path fill-rule="evenodd" d="M5 1.75C5 .784 5.784 0 6.75 0h7.5C15.216 0 16 .784 16 1.75v7.5A1.75 1.75 0 0114.25 11h-7.5A1.75 1.75 0 015 9.25v-7.5zm1.75-.25a.25.25 0 00-.25.25v7.5c0 .138.112.25.25.25h7.5a.25.25 0 00.25-.25v-7.5a.25.25 0 00-.25-.25h-7.5z"></path> </svg>';
        const successInnerHTML = '<svg height="1em" fill="currentColor" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M13.78 4.22a.75.75 0 010 1.06l-7.25 7.25a.75.75 0 01-1.06 0L2.22 9.28a.75.75 0 011.06-1.06L6 10.94l6.72-6.72a.75.75 0 011.06 0z"></path></svg>';
        codeBlocks.forEach(function (codeBlock) {
            // Create a copy button element
            const copyButton = document.createElement('button');
            copyButton.className = 'bg-emerald-500 p-2 text-white fadeIn shadow-xl rounded flex items-center absolute top-2 right-2';
            copyButton.innerHTML = initInnerHTML;
            copyButton.style.opacity = "0";
            const parent = codeBlock.parentNode;

            parent.style = "position: relative;"
            parent.insertBefore(copyButton, codeBlock);

            // Add click event listener to copy button
            copyButton.addEventListener('click', () => {
                navigator.clipboard.writeText(codeBlock.textContent).then(() => {
                    copyButton.innerHTML = successInnerHTML;
                    setTimeout(() => {
                        copyButton.innerHTML = initInnerHTML;
                    }, 1000);
                });
            });

            parent.addEventListener('mouseenter', () => {
                copyButton.style.opacity = "1";
            });
            parent.addEventListener('mouseleave', () => {
                copyButton.style.opacity = "0";
            });
        });
    </script><script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "url": "https://quickref.me",
      "logo": "https://quickref.me/images/favicon.png",
      "description": "Quick Reference CheatSheet - share quick reference and cheat sheet for developers",
      "name": "QuickRef.ME",
      "contactPoint": {
        "contactType": "customer support",
        "email": "support@quickref.me"
      }
    }</script><script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": [
        {
          "@type": "ListItem",
          "position": 1,
          "name": "Home",
          "item": "https://quickref.me/"
        },
        {
          "@type": "ListItem",
          "position": 2,
          "name": "YAML Cheat Sheet & Quick Reference",
          "item": "https://quickref.me/yaml"
        }
      ]
    }</script></body></html>