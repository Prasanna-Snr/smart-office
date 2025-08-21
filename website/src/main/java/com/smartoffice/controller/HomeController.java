package com.smartoffice.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("title", "Smart Office Dashboard");
        return "index";
    }

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("title", "Smart Office Dashboard");
        return "index";
    }
}