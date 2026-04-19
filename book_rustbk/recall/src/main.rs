use std::io;

fn main() {
    println!("A program that takes three inputs and calculates the average");

    let mut a = String::new();
    let mut b = String::new();
    let mut c = String::new();

    println!("Enter first number");
    io::stdin()
        .read_line(&mut a)
        .expect("Failed to read first number");

    println!("Enter second number");
    io::stdin()
        .read_line(&mut b)
        .expect("Failed to read second number");

    println!("Enter third number");
    io::stdin()
        .read_line(&mut c)
        .expect("Failed to read third number");

    // The conversation from string to  floating point

    let num01: f64 = a.trim().parse().expect("Please type a valid first number");
    let num02: f64 = b.trim().parse().expect("Please type a valid second number");
    let num03: f64 = c.trim().parse().expect("Please type a valid third number");

    // The calculaion

    let sum: f64 = num01 + num02 + num03;
    let average: f64 = sum / 3.0;

    println!("The avarage value is {}", average)
}
