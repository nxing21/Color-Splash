# Color-Splash
A personal project I completed. See ColorSplash.docx for details about the project.

How to use it?

![Splash1](https://github.com/user-attachments/assets/c7adaaa0-c530-4772-a774-21ec153392f5)

Menu:
1.	Load image: load image file to edit
2.	Add color: pick another color to current selection(s)
3.	Clear all: re-start from original image

Tolerance bar: Adjust threshold of color tolerance for every single color. Selected color is displayed by the side of tolerance bar.

Fill hole: fill holes or not in the selected colors

Example1: Single-color splash

![Splash2](https://github.com/user-attachments/assets/d68c22fb-8da0-4e57-acf6-6e5b3ff4f6b7)

Example2: Two-color splash

![Splash3](https://github.com/user-attachments/assets/0b815125-d32a-4142-a9d8-48b7acbe27d6)

Example3: Single-color splash with hole filled

![Splash4](https://github.com/user-attachments/assets/6ab518af-0146-4453-b34c-f8356fd2e269)

YUV color space was chosen for color selection

![Splash5](https://github.com/user-attachments/assets/e1ff59e9-fe7f-45e5-a16c-33fd7423be71)
![Splash6](https://github.com/user-attachments/assets/fc48558e-dd99-4b48-b95f-d0bd7e89520c)

Algorithm details:
1.	Convert the image into YUV color space. Only blue luminance (U) and red luminance (V) were used

![Splash7](https://github.com/user-attachments/assets/ca97d4cc-b30f-414e-91a3-21b3e1465346)
![Splash8](https://github.com/user-attachments/assets/292cb30e-f4eb-4f2f-8931-11213647c961)

2.	Obtain the selected color by averaging a very small region of selected points (e.g. 7*7 pixels)

![Splash9](https://github.com/user-attachments/assets/0870661a-0c71-44cb-8762-c4e1fa2a2409)
![Splash10](https://github.com/user-attachments/assets/b25a64d9-afb9-4dc0-b694-3a188a9d87d5)

3.	Calculate the Euclidean distance based on the selected color

![Splash11](https://github.com/user-attachments/assets/7a8ef3c9-6573-40dd-a4e8-8678deb1662f)

4.	Normalize the distance by the feather parameter

![Splash12](https://github.com/user-attachments/assets/ca673c2e-9abf-4b6c-bdec-586983bf5ae3)

5.	Transform the normalized distance to a probability distribution by applying Sigmoid function and mapping it to the [0,1] range

![Splash13](https://github.com/user-attachments/assets/66606b83-76bd-4f98-8726-67584c7c8461)

6.	Estimate the mask by applying a threshold to the probability distribution. The threshold could be adjustable by the user.

![Splash14](https://github.com/user-attachments/assets/ce8cfda6-8b4d-4315-b3da-0be7db9b171e)
![Splash15](https://github.com/user-attachments/assets/72e9e279-f05f-4659-890f-6cc60178c0cb)

7.	Fill the holes in the mask using Morphological reconstruction method. This is an optional step, user could simply enable or disable this feature.

![Splash16](https://github.com/user-attachments/assets/b24e6e32-3b1c-4008-910f-8fe9a2ea2e43)
 
8.	Use the mask to combine the colored image and its mono version to get the final output

![Splash17](https://github.com/user-attachments/assets/04d48b19-2010-481f-b63f-b811516e6f40)
![Splash18](https://github.com/user-attachments/assets/157e98d9-3dd7-43a0-bc67-663436ae4802)

More examples:

![Splash19](https://github.com/user-attachments/assets/b1a4c9ce-96cd-4abb-b8db-a1f9d51ba03b)
Enjoy!
